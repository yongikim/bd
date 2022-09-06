// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bd/repository/expense_repository.dart';
import 'package:bd/model/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Expense create test', () async {
    final ExpenseRepository repo = ExpenseRepository();
    await repo.init(dbName: "test");

    Expense expense = Expense(
      "test",
      100,
      2022,
      9,
      3,
    );
    Expense insertedExpense = await repo.insertExpense(expense);

    Expense readExpense = await repo.findExpenseByID(insertedExpense.id!);

    expect(insertedExpense, readExpense);

    repo.deleteCurrentDB();
  });
}
