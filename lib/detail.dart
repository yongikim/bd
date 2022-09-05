import 'package:bd/home_tab_view.dart';
import 'package:bd/int_extension.dart';
import 'package:bd/new_record.dart';
import 'package:flutter/material.dart';

import 'model/expense.dart';

class Detail extends StatefulWidget {
  const Detail({
    Key? key,
    required this.summary,
    required this.heroTag,
  }) : super(key: key);

  final ExpenseSummary summary;
  final String heroTag;

  @override
  State<Detail> createState() => _Detail();
}

class _Detail extends State<Detail> {
  late Future<Map<int, List<Expense>>> _expenses;

  @override
  void initState() {
    super.initState();

    _expenses = _getExpenses();
  }

  Future<Map<int, List<Expense>>> _getExpenses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    Map<int, List<Expense>> data = {};
    for (int i = 0; i < 15; i++) {
      data.putIfAbsent(i, () => []);
      data[i]!.add(
        Expense(
          widget.summary.name,
          i * 10,
          widget.summary.year,
          widget.summary.month,
          i + 1,
        ),
      );
      data[i]!.add(
        Expense(
          widget.summary.name,
          i * 10,
          widget.summary.year,
          widget.summary.month,
          i + 1,
        ),
      );
    }
    return data;
  }

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

  // 記録作成画面
  void _showNewRecordModal() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => const NewRecord(),
    ).whenComplete(
      () => setState(() {
        // Do Something
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseSummary summary = widget.summary;

    const appBarHeight = 70.0;
    const bottomBarHeight = 40 + 48;
    final safeAreaPaddingHeight = MediaQuery.of(context).padding.top;
    final containerHeight = MediaQuery.of(context).size.height -
        (appBarHeight + bottomBarHeight + safeAreaPaddingHeight);

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
              child: Text(
                summary.amount.toPriceString(),
                style: const TextStyle(
                  fontSize: 36,
                ),
              ),
            ),
          ),
          // 内訳リスト
          Expanded(
            // fit: FlexFit.loose,
            child: FutureBuilder<Map<int, List<Expense>>>(
              future: _expenses,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: CustomScrollView(
                      shrinkWrap: true,
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            _buildDailyExpenses(snapshot.data!),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Hero(
        tag: widget.heroTag,
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
                          summary.name.toString(),
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
                  onPressed: () {
                    _showNewRecordModal();
                  },
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
