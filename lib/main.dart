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
  final _nameFieldController = TextEditingController();
  final _amountFieldController = TextEditingController();
  List<int> _candidateAmounts = [];
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  String _newRecordName = '';
  int _newRecordAmount = 0;
  FocusNode _amountFocusNode = FocusNode();

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

  // TODO: Get from Real Database
  Future<List<String>> _getCandidateNames() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['スタバ', 'タリーズ', 'ドトール'];
  }

  Future<void> _handleCandidateNameClick(String name) async {
    // FIXME: 名前候補を再選択したとき金額候補の変更を反映するために一度フォーカスを外す
    FocusManager.instance.primaryFocus?.unfocus();

    // 名前の設定
    setState(() {
      _newRecordName = name;
    });
    _nameFieldController.text = name;

    // 金額候補の取得
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      setState(() {
        if (name == 'スタバ') {
          _candidateAmounts = [100, 200, 300];
        } else if (name == 'タリーズ') {
          _candidateAmounts = [10, 20, 30];
        } else if (name == 'ドトール') {
          _candidateAmounts = [1000, 2000, 3000];
        }
      });
      // 金額フォームにフォーカスを当てる
      _amountFocusNode.requestFocus();
    });
  }

  Future<void> _handleCandidateAmountClick(int amount) async {
    // 金額の設定
    setState(() {
      _newRecordAmount = amount;
    });
    _amountFieldController.text = amount.toString();
    // 金額フォームにフォーカスを当てる
    // _amountFocusNode.requestFocus();
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
              // 完了ボタン
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
              // 名前フォーム
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _nameFieldController,
                  enabled: true,
                  autofocus: true,
                  onChanged: _handleNewRecordNameChange,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
              ),
              // 名前候補
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FutureBuilder(
                    future: _getCandidateNames(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          children: snapshot.data!
                              .map(
                                (name) => Card(
                                  elevation: 2,
                                  child: TextButton(
                                    onPressed: () async {
                                      await _handleCandidateNameClick(name);
                                    },
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              // 金額フォーム
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _amountFieldController,
                  focusNode: _amountFocusNode,
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
              // 金額候補
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _candidateAmounts
                        .map(
                          (amount) => Card(
                            elevation: 2,
                            child: TextButton(
                              onPressed: () async {
                                await _handleCandidateAmountClick(amount);
                              },
                              child: Text(
                                amount.toString(),
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(
      () => setState(() {
        _nameFieldController.text = '';
        _amountFieldController.text = '';
        _newRecordName = '';
        _newRecordAmount = 0;
        _candidateAmounts = [];
      }),
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
