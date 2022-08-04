import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_tab_view.dart';

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
  late List<int> _monthsThisYear;
  late TabController _tabController;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  String _newRecordName = '';
  int _newRecordAmount = 0;

  @override
  void initState() {
    super.initState();

    _monthsThisYear = _getMonthsThisYear();

    _tabController = TabController(
      vsync: this,
      length: _monthsThisYear.length,
      initialIndex: _monthsThisYear.length - 1,
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

  List<int> _getMonthsThisYear() {
    List<int> months = List.generate(_month, (index) => index + 1);
    return months;
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
          children: List.generate(
            _monthsThisYear.length,
            (index) => HomeTabView(
              year: _year,
              month: _monthsThisYear[index],
            ),
          ),
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
