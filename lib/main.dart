import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _month = DateTime.now().month;
  String _newRecordName = '';
  int _newRecordAmount = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 2,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final int prevIndex = _tabController.previousIndex;
        final int nextIndex = _tabController.index;
        if (nextIndex < prevIndex) {
          setState(() {
            _month = _month - 1;
          });
        } else {
          setState(() {
            _month = _month + 1;
          });
        }
      }
    });
  }

  void _handleNewRecordNameChange(String input) {
    setState(() {
      _newRecordName = input;
    });
  }

  void _handleNewRecordAmountChange(String input) {
    int? amount = int.tryParse(input);
    if (amount == null) {}

    setState(() {
      _newRecordAmount = amount!;
    });
  }

  void _showNewRecordModal() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.only(top: 64),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.done,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  enabled: true,
                  autofocus: true,
                  onChanged: _handleNewRecordNameChange,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
              ),
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: const Center(child: Text('スタバ')),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: const Center(child: Text('スタバ')),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: const Center(child: Text('スタバ')),
                      ),
                    ),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  enabled: true,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: _handleNewRecordAmountChange,
                  decoration: const InputDecoration(hintText: 'Amount'),
                ),
              ),
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: Center(child: Text(500.toString())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: Center(child: Text(500.toString())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: Center(child: Text(500.toString())),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 70,
                pinned: true,
                snap: false,
                floating: true,
                backgroundColor: Theme.of(context).canvasColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _month.toString(),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.overline?.color,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            HomeTabView(month: _month - 2),
            HomeTabView(month: _month - 1),
            HomeTabView(month: _month),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        child: ElevatedButton(
          onPressed: _showNewRecordModal,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Icon(
            Icons.add,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class HomeTabView extends StatefulWidget {
  const HomeTabView({Key? key, required this.month}) : super(key: key);

  final int month;

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView>
    with AutomaticKeepAliveClientMixin<HomeTabView> {
  @override
  bool get wantKeepAlive => true;

  late Future<int> _future;
  late bool _seeAllRecurring;
  late bool _seeAllTemporary;

  @override
  void initState() {
    super.initState();
    _future = getMonth();
    _seeAllRecurring = false;
    _seeAllTemporary = false;
  }

  Future<int> getMonth() async {
    await Future.delayed(const Duration(seconds: 3));
    return widget.month;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return SafeArea(
            top: true,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 50,
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '\u{1f3E0} Recurring',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _seeAllRecurring = !_seeAllRecurring;
                              });
                            },
                            child: _seeAllRecurring
                                ? const Text('See Less')
                                : const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _seeAllRecurring
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return SizedBox(
                                height: 180,
                                width: 188,
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  margin: EdgeInsetsDirectional.only(
                                    top: 8,
                                    bottom: 8,
                                    start: index % 2 == 0 ? 16 : 8,
                                    end: index % 2 == 0 ? 8 : 16,
                                  ),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              );
                            },
                            childCount: 5,
                          ),
                        )
                      : SliverToBoxAdapter(
                          child: SizedBox(
                            height: 180,
                            child: CustomScrollView(
                              scrollDirection: Axis.horizontal,
                              slivers: [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return SizedBox(
                                        height: 180,
                                        width: index == 0 || index == 4
                                            ? 188
                                            : 180,
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          margin: EdgeInsetsDirectional.only(
                                              top: 8,
                                              bottom: 8,
                                              start: index == 0 ? 16 : 8,
                                              end: index == 4 ? 16 : 8),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: 5,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '\u{1f3ce} Temporary',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _seeAllTemporary = !_seeAllTemporary;
                              });
                            },
                            child: const Text('See All'),
                          )
                        ],
                      ),
                    ),
                  ),
                  _seeAllTemporary
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return SizedBox(
                                height: 180,
                                width: 188,
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  margin: EdgeInsetsDirectional.only(
                                    top: 8,
                                    bottom: 8,
                                    start: index % 2 == 0 ? 16 : 8,
                                    end: index % 2 == 0 ? 8 : 16,
                                  ),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              );
                            },
                            childCount: 5,
                          ),
                        )
                      : SliverToBoxAdapter(
                          child: SizedBox(
                            height: 180,
                            child: CustomScrollView(
                              scrollDirection: Axis.horizontal,
                              slivers: [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return SizedBox(
                                        height: 180,
                                        width: index == 0 || index == 4
                                            ? 188
                                            : 180,
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          margin: EdgeInsetsDirectional.only(
                                              top: 8,
                                              bottom: 8,
                                              start: index == 0 ? 16 : 8,
                                              end: index == 4 ? 16 : 8),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
