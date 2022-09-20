import 'package:bd/model/expense.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../home_tab_view.dart';

class ExpenseRepository {
  ExpenseRepository();

  late Database _db;
  late String _dbPath;

  Future init({String dbName = "dev1"}) async {
    _db = await _getDatabase(dbName);
  }

  Future<Database> _getDatabase(String dbName) async {
    String dbPath = await getDatabasesPath();
    dbPath += '$dbName.db';
    _dbPath = dbPath;
    return openDatabase(
      _dbPath,
      version: 1,
      onCreate: (Database newDB, int version) {
        newDB.execute("""
          CREATE TABLE Expense
            (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              amount INTEGER,
              year INTEGER,
              month INTEGER,
              day INTEGER
            )
        """);
      },
    );
  }

  deleteCurrentDB() {
    deleteDatabase(_dbPath);
  }

  Future<Expense> insertExpense(Expense expense) async {
    int id = await _db.insert('expense', expense.toMap());
    expense.id = id;
    return expense;
  }

  Future<Expense> findExpenseByID(int id) async {
    List<Map<String, Object?>> records =
        await _db.query('expense', where: 'id = ?', whereArgs: [id]);
    Map<String, Object?> mapRead = records.first;
    final Expense expense = Expense.fromMap(mapRead);
    expense.id = id;
    return expense;
  }

  // データベースから、`year` / `month` に作成された
  // 記録の名前を取得し、金額で降順にソートして返す。
  Future<List<String>> expenseNames(int year, int month) async {
    final summaries = await getExpenseSummaries(year, month);

    summaries.sort((a, b) => b.amount.compareTo(a.amount));

    return summaries
        .map(
          (e) => e.name,
        )
        .toList();
  }

  Future<List<ExpenseSummary>> getExpenseSummaries(int year, int month) async {
    final Map<String, ExpenseSummary> summaryMap = {};
    final List<Map<String, dynamic>> expenses = await _db.query(
      'expense',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );

    for (var expense in expenses) {
      ExpenseSummary? summary = summaryMap[expense['name']];
      if (summary == null) {
        summary = ExpenseSummary(
          expense['name'],
          expense['amount'],
          expense['year'],
          expense['month'],
        );
        summaryMap[expense['name']] = summary;
      } else {
        final int amount = expense['amount'];
        summary.amount += amount;
        summary.recurring = true;
      }
    }

    return summaryMap.values.toList();
  }
}
