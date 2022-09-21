import 'package:bd/repository/expense_repository.dart';
import 'package:bd/riverpods/expense_summary_provider.dart';
import 'package:bd/riverpods/expenses_provider.dart';
import 'package:bd/utility/int_extension.dart';
import 'package:bd/new_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import 'model/expense.dart';

class Detail extends ConsumerWidget {
  const Detail({
    Key? key,
    required this.year,
    required this.month,
    required this.summaryName,
    required this.heroTag,
  }) : super(key: key);

  final int year;
  final int month;
  final String summaryName;
  final String heroTag;

  // `day` でグループ化
  Map<int, List<Expense>> _groupByDay(List<Expense> expenses) {
    Map<int, List<Expense>> data = {};
    for (Expense expense in expenses) {
      data.putIfAbsent(expense.day, () => []);
      data[expense.day]!.add(expense);
    }
    return data;
  }

  // 取得した記録を、日付でグループ化して表示
  //
  // ex.) day 15  140
  //              130
  //      day 13  120
  //      day 12  110
  //
  List<Widget> _buildDailyExpenses(
    Map<int, List<Expense>> expensesMap,
  ) {
    return expensesMap.entries
        .map((e) {
          int day = e.key;
          List<Expense> expenses = e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('Day $day'),
                ),
                Column(
                  children: expenses.map((expense) {
                    return Row(
                      children: [
                        const Spacer(),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            expense.amount.toPriceString(),
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        })
        .toList()
        .reversed
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const appBarHeight = 70.0;
    const bottomBarHeight = 40 + 48;
    final safeAreaPaddingHeight = MediaQuery.of(context).padding.top;
    final containerHeight = MediaQuery.of(context).size.height -
        (appBarHeight + bottomBarHeight + safeAreaPaddingHeight);

    // Provider から ExpenseSummary を取得
    final targetSummaryProvider = expenseSummaryProvider(
      Tuple3(
        year,
        month,
        summaryName,
      ),
    );
    final summary = ref.watch(targetSummaryProvider);

    // Provider から Expense のリストを取得
    final targetExpensesProvider = expensesProvider(
      Tuple3(
        year,
        month,
        summaryName,
      ),
    );
    final expenses = ref.watch(targetExpensesProvider);

    // 記録作成モーダル。モーダルを閉じると詳細画面に戻る。
    showNewRecordModal() {
      return () async {
        await showModalBottomSheet<void>(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (context) => NewRecord(expenseName: summaryName),
        );
        // 詳細画面をリフレッシュ `widget.summary` と `_expenses`
        ref.refresh(targetSummaryProvider);
        ref.refresh(targetExpensesProvider);
      };
    }

    Widget buildSummaryAmount() {
      Widget widget = const Center(
        child: CircularProgressIndicator(),
      );
      summary.when(
        data: (data) {
          widget = Text(
            data.amount.toPriceString(),
            style: const TextStyle(
              fontSize: 36,
            ),
          );
        },
        error: (e, t) {
          widget = const Center(
            child: Text("error"),
          );
        },
        loading: () {
          widget = const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      return widget;
    }

    Widget buildExpenseList() {
      Widget widget = const Center(
        child: CircularProgressIndicator(),
      );
      expenses.when(
        data: (data) {
          widget = Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    _buildDailyExpenses(_groupByDay(data)),
                  ),
                ),
              ],
            ),
          );
        },
        error: (e, t) {
          widget = const Center(
            child: Text("error"),
          );
        },
        loading: () {
          widget = const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      return widget;
    }

    final container = SizedBox(
      height: containerHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 総額
          Container(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: buildSummaryAmount(),
            ),
          ),
          // 内訳リスト
          Expanded(
            // fit: FlexFit.loose,
            child: buildExpenseList(),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Hero(
        tag: heroTag,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            Navigator.of(context).pop();
          },
          child: Material(
            type: MaterialType.transparency,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(appBarHeight),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        // 項目の名前
                        Text(
                          summaryName.toString(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.overline?.color,
                            fontSize: 16,
                          ),
                        ),
                        // "Close" ボタン
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: const ButtonStyle(
                              alignment: Alignment.centerRight,
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: container,
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
            ),
          ),
        ),
      ),
    );
  }
}
