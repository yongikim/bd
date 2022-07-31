import 'package:flutter/material.dart';

import 'home_app_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
            SafeArea(
              top: true,
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: CustomScrollView(
                  slivers: [
                    const _RowHeader(title: 'Recurring'),
                    SliverGrid.count(
                      crossAxisCount: 2,
                      children: [
                        Container(color: Colors.red),
                        Container(color: Colors.blue),
                        Container(color: Colors.blue),
                        Container(color: Colors.red),
                      ],
                    ),
                    const _RowHeader(title: 'Temporary'),
                    SliverGrid.count(
                      crossAxisCount: 2,
                      children: [
                        Container(color: Colors.red),
                        Container(color: Colors.blue),
                        Container(color: Colors.blue),
                        Container(color: Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Row(
                    children: const <Widget>[
                      Expanded(child: Text('Recurring')),
                      Expanded(child: Icon(Icons.add)),
                    ],
                  ),
                )
              ],
            ),
            Column(
              children: [
                Expanded(
                  child: Row(
                    children: const <Widget>[
                      Expanded(child: Text('Recurring')),
                      Expanded(child: Icon(Icons.add)),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RowHeader extends StatelessWidget {
  const _RowHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            TextButton(
              onPressed: () {},
              child: const Text('確認用'),
            )
          ],
        ),
      ),
    );
  }
}
