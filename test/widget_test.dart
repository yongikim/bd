// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bd/db_provider.dart';
import 'package:bd/model/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Expense create test', () async {
    final DBProvider provider = DBProvider();
    await provider.init(dbName: "test");

    Expense expense = Expense(
      "test",
      100,
      2022,
      9,
      3,
    );
    Expense insertedExpense = await provider.insertExpense(expense);

    Expense readExpense = await provider.findExpenseByID(insertedExpense.id!);

    expect(insertedExpense, readExpense);

    provider.deleteCurrentDB();
  });
}
