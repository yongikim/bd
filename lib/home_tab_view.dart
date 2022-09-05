import 'package:bd/db_provider.dart';
import 'package:bd/int_extension.dart';
import 'package:bd/model/expense.dart';
import 'package:flutter/material.dart';

import 'detail.dart';

class ExpenseSummary {
  late String name;
  late int amount;
  late int year;
  late int month;
  bool recurring = false;

  ExpenseSummary(
    this.name,
    this.amount,
    this.year,
    this.month,
  );
}

class HomeTabView extends StatefulWidget {
  const HomeTabView({
    Key? key,
    required this.year,
    required this.month,
  }) : super(key: key);

  final int year;
  final int month;

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView>
    with AutomaticKeepAliveClientMixin<HomeTabView> {
  @override
  bool get wantKeepAlive => true;

  // 指定された year, month の記録
  late Future<List<ExpenseSummary>> _summaries;

  // SummaryCards を展開し、グリッドで表示するかどうか
  late bool _seeAllRecurring;
  late bool _seeAllTemporary;

  @override
  void initState() {
    super.initState();

    _summaries = fetchExpenseSummaries();

    // デフォルトは横スクロール表示
    _seeAllRecurring = false;
    _seeAllTemporary = false;
  }

  // 指定された year, month の記録をデータベースから全て取得する
  Future<List<ExpenseSummary>> fetchExpenseSummaries() async {
    Map<String, List<ExpenseSummary>> data = {};

    DBProvider dbProvider = DBProvider();
    await dbProvider.init();

    final summaries = dbProvider.getExpenseSummaries(
      widget.year,
      widget.month,
    );

    setState(() {
      _summaries = summaries;
    });

    return summaries;
    // List<ExpenseSummary> recurring =
    //     summaries.where((s) => s.recurring).toList();
    // List<ExpenseSummary> temporary =
    //     summaries.where((s) => !s.recurring).toList();

    // data['recurring'] = recurring;
    // data['temporary'] = temporary;

    // return data;
  }

  _handleSummaryCardTap(ExpenseSummary summary, String heroTag) {
    Navigator.push(
      context,
      PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, Animation<double> animation, ___) {
            return FadeTransition(
              opacity: animation,
              child: Detail(
                summary: summary,
                heroTag: heroTag,
              ),
            );
          }),
    );
  }

  Widget summaryCard(ExpenseSummary summary, EdgeInsets margin) {
    final String heroTag =
        '${summary.year}${summary.month}${summary.name}${DateTime.now().hashCode}';
    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () {
            _handleSummaryCardTap(summary, heroTag);
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            margin: margin,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text('${widget.month} ${summary.name}',
                        style: const TextStyle(
                          fontSize: 14,
                        )),
                  ),
                  const Spacer(),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      summary.amount.toPriceString(),
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 予算
                  // Container(
                  //   alignment: Alignment.centerLeft,
                  //   child: const Text(
                  //     'Budget',
                  //     style: TextStyle(
                  //       fontSize: 10,
                  //       color: Colors.black45,
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   alignment: Alignment.centerRight,
                  //   child: Text(
                  //     summary.amount.toString(),
                  //     style: const TextStyle(
                  //       fontSize: 14,
                  //       color: Colors.black45,
                  //     ),
                  //   ),
                  // ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Last Month',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      summary.amount.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _summaries,
      builder:
          (BuildContext context, AsyncSnapshot<List<ExpenseSummary>> snapshot) {
        if (snapshot.hasData) {
          List<ExpenseSummary> recurring =
              snapshot.data!.where((e) => e.recurring).toList();
          List<ExpenseSummary> temporary =
              snapshot.data!.where((e) => !e.recurring).toList();
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
                      ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            delegate: SliverChildListDelegate(
                              recurring.asMap().entries.map((e) {
                                return summaryCard(
                                  e.value,
                                  const EdgeInsets.all(5),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : SliverToBoxAdapter(
                          child: SizedBox(
                            height: 170,
                            child: CustomScrollView(
                              scrollDirection: Axis.horizontal,
                              slivers: [
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                    recurring.asMap().entries.map((e) {
                                      return SizedBox(
                                        width: e.key == 0 ||
                                                e.key == recurring.length - 1
                                            ? 180
                                            : 170,
                                        child: summaryCard(
                                          e.value,
                                          EdgeInsets.only(
                                            top: 5,
                                            bottom: 5,
                                            left: e.key == 0 ? 15 : 5,
                                            right: e.key == recurring.length - 1
                                                ? 15
                                                : 5,
                                          ),
                                        ),
                                      );
                                    }).toList(),
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
                            child: _seeAllTemporary
                                ? const Text('See Less')
                                : const Text('See All'),
                          )
                        ],
                      ),
                    ),
                  ),
                  _seeAllTemporary
                      ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            delegate: SliverChildListDelegate(
                              temporary.asMap().entries.map((e) {
                                return summaryCard(
                                  e.value,
                                  const EdgeInsets.all(5),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : SliverToBoxAdapter(
                          child: SizedBox(
                            height: 170,
                            child: CustomScrollView(
                              scrollDirection: Axis.horizontal,
                              slivers: [
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                    temporary.asMap().entries.map((e) {
                                      return SizedBox(
                                        width: e.key == 0 ||
                                                e.key == temporary.length - 1
                                            ? 180
                                            : 170,
                                        child: summaryCard(
                                          e.value,
                                          EdgeInsets.only(
                                            top: 5,
                                            bottom: 5,
                                            left: e.key == 0 ? 15 : 5,
                                            right: e.key == temporary.length - 1
                                                ? 15
                                                : 5,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
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
