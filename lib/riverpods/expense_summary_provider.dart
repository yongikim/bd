import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import '../repository/expense_repository.dart';
import '../home_tab_view.dart';

final expenseSummaryProvider =
    FutureProvider.family<List<ExpenseSummary>, Tuple2<int, int>>(
  (ref, tuple) async {
    final repository = ExpenseRepository();
    await repository.init();

    final year = tuple.item1;
    final month = tuple.item2;
    final summaries = await repository.getExpenseSummaries(
      year,
      month,
    );

    return summaries;
  },
);
