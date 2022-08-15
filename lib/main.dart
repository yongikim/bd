import 'package:bd/new_record.dart';
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

  // 記録作成画面
  void _showNewRecordModal() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => const NewRecord(),
    ).whenComplete(
      () => setState(() {
        // Do Something
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
