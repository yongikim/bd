import 'package:bd/expense_provider.dart';
import 'package:bd/model/expense.dart';
import 'package:bd/new_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_tab_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: const MyApp(),
    ),
  );
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int get _prevTabIndex => _tabController.previousIndex;
  int get _nextTabIndex => _tabController.index;
  late TabController _tabController;
  late List<HomeTabView> _tabs;
  int _month = DateTime.now().month;

  @override
  void initState() {
    super.initState();

    List<int> months = _getMonthsThisYear();

    _tabController = TabController(
      vsync: this,
      length: months.length,
      initialIndex: months.length - 1,
    );

    Function() listner = _createTabChangeListener(_tabController);
    _tabController.addListener(listner);

    int year = DateTime.now().year;
    _tabs = List.generate(
      months.length,
      (index) => HomeTabView(
        year: year,
        month: months[index],
      ),
    );
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  // TabControllerに紐付けられたlistener関数を生成する関数
  Function() _createTabChangeListener(TabController controller) {
    return () {
      if (!controller.indexIsChanging) {
        final int prevIndex = _prevTabIndex;
        final int nextIndex = _nextTabIndex;
        final int prevMonth = _tabs[prevIndex].month;
        final int prevYear = _tabs[prevIndex].year;
        if (nextIndex == 0) {
          // 左端のタブに到達する前に左端に2ヶ月前のタブを追加
          int year, month;
          if (prevMonth > 2) {
            year = prevYear;
            month = prevMonth - 2;
          } else {
            year = prevYear - 1;
            month = prevMonth + 10;
          }

          // Deep Copy
          List<HomeTabView> newTabs = [..._tabs];
          newTabs.insert(
            0,
            HomeTabView(year: year, month: month),
          );

          // タブの増加に対応したTabControllerに差し替える
          TabController newController = TabController(
            // length: newTabs.length,
            length: _tabs.length + 1,
            vsync: this,
            initialIndex: nextIndex + 1,
          );
          Function() listener = _createTabChangeListener(controller);
          newController.addListener(listener);

          setState(() {
            _tabs = newTabs;
            _tabController = newController;
            _month = _tabs[nextIndex + 1].month;
          });
        } else {
          setState(() {
            _month = _tabs[nextIndex].month;
          });
        }
      }
    };
  }

  List<int> _getMonthsThisYear() {
    int month = DateTime.now().month;
    List<int> months = List.generate(month, (index) => index + 1);
    return months;
  }

  // 記録作成画面
  _showNewRecordModal(BuildContext context, ExpenseProvider provider) {
    return () async {
      await showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => const NewRecord(),
      );
      print('complete');
      setState(() {});
      // await provider.fetchExpenses(year, month),
    };
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
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        child: Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
          return ElevatedButton(
            onPressed: _showNewRecordModal(context, expenseProvider),
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
          );
        }),
      ),
    );
  }
}
