import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import '../repository/expense_repository.dart';
import '../home_tab_view.dart';

final expenseSummaryProvider =
    FutureProvider.family<ExpenseSummary, Tuple3<int, int, String>>(
  (ref, tuple) async {
    final year = tuple.item1;
    final month = tuple.item2;
    final name = tuple.item3;
    final summary = await ExpenseRepository.summaryByYearMonthName(
      year,
      month,
      name,
    );

    return summary;
  },
);
