import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import '../model/expense.dart';
import '../repository/expense_repository.dart';

final expensesProvider =
    FutureProvider.family<List<Expense>, Tuple3<int, int, String>>(
  (ref, tuple) async {
    final year = tuple.item1;
    final month = tuple.item2;
    final name = tuple.item3;
    final expenses = await ExpenseRepository.findByYearMonthName(
      year,
      month,
      name,
    );

    return expenses;
  },
);
