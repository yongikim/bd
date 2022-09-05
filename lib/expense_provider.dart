import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'db_provider.dart';
import 'home_tab_view.dart';
import 'model/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final Map<String, List<ExpenseSummary>> _summaries = {};
  final DBProvider _db = DBProvider();
  bool _initiated = false;

  Map<String, List<ExpenseSummary>> get summaries => _summaries;

  Future _ensureDBInitiated() async {
    if (_initiated) return;

    await _db.init();
    _initiated = true;
  }

  Future fetchExpenses(int year, int month) async {
    await _ensureDBInitiated();

    final summariesPart = await _db.getExpenseSummaries(year, month);
    final key = '$year$month';
    _summaries[key] = summariesPart;

    notifyListeners();
  }

  Future create(Expense expense) async {
    await _ensureDBInitiated();

    await _db.insertExpense(expense);
    await fetchExpenses(expense.year, expense.month);

    notifyListeners();
  }
}
