import 'package:bd/utility/int_extension.dart';
import 'package:bd/riverpods/expense_summaries_provider.dart';
import 'package:bd/riverpods/toggle_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import 'detail.dart';
import 'new_record.dart';

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

class HomeTabView extends ConsumerWidget {
  const HomeTabView({
    Key? key,
    required this.year,
    required this.month,
  }) : super(key: key);

  final int year;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAllRecurring = ref.watch(showAllRecurringProvider);
    final showAllTemporary = ref.watch(showAllTemporaryProvider);
    final targetExpeseProvider = expenseSummariesProvider(Tuple2(year, month));
    final summaries = ref.watch(targetExpeseProvider);

    handleSummaryCardTap(
      BuildContext context,
      ExpenseSummary summary,
      String heroTag,
    ) {
      Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, Animation<double> animation, ___) {
              return FadeTransition(
                opacity: animation,
                child: Detail(
                  year: year,
                  month: month,
                  summaryName: summary.name,
                  heroTag: heroTag,
                ),
              );
            }),
      ).then((value) {
        // Wait for animation
        Future.delayed(const Duration(milliseconds: 300)).then(
          (value) => ref.refresh(targetExpeseProvider),
        );
      });
    }

    Widget summaryCard(
      BuildContext context,
      ExpenseSummary summary,
      EdgeInsets margin,
    ) {
      final String heroTag =
          '${summary.year}${summary.month}${summary.name}${DateTime.now().hashCode}';
      return Hero(
        tag: heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: () {
              handleSummaryCardTap(
                context,
                summary,
                heroTag,
              );
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
                      child: Text(
                        summary.name,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
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

    // 記録作成画面
    showNewRecordModal() {
      return () async {
        await showModalBottomSheet<void>(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) => const NewRecord(),
        );
        ref.refresh(targetExpeseProvider);
      };
    }

    return summaries.when(
      data: (summariesData) {
        List<ExpenseSummary> recurring =
            summariesData.where((e) => e.recurring).toList();
        recurring.sort((a, b) => b.amount.compareTo(a.amount));
        List<ExpenseSummary> temporary =
            summariesData.where((e) => !e.recurring).toList();
        temporary.sort((a, b) => b.amount.compareTo(a.amount));
        return Scaffold(
          body: SafeArea(
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
                              ref
                                  .read(showAllRecurringProvider.notifier)
                                  .state = !showAllRecurring;
                            },
                            child: showAllRecurring
                                ? const Text('See Less')
                                : const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  showAllRecurring
                      ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            delegate: SliverChildListDelegate(
                              recurring.asMap().entries.map((e) {
                                return summaryCard(
                                  context,
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
                                          context,
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
                              ref
                                  .read(showAllTemporaryProvider.notifier)
                                  .state = !showAllTemporary;
                            },
                            child: showAllTemporary
                                ? const Text('See Less')
                                : const Text('See All'),
                          )
                        ],
                      ),
                    ),
                  ),
                  showAllTemporary
                      ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            delegate: SliverChildListDelegate(
                              temporary.asMap().entries.map((e) {
                                return summaryCard(
                                  context,
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
                                          context,
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
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 16,
              right: 16,
              bottom: 32,
            ),
            child: ElevatedButton(
              onPressed: showNewRecordModal(),
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
      },
      error: (e, t) {
        return const Center(
          child: Text("error"),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
