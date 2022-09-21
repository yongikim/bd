import 'package:bd/model/expense.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../home_tab_view.dart';

class ExpenseRepository {
  // TODO: DBを引数として受け取り、テスト可能な実装にする。
  // sqflite は `flutter test` に対応していない。

  // Make this singleton class
  // クラスのスタティックメンバとしてインスタンスのキャッシュを保持
  static final ExpenseRepository _instance = ExpenseRepository._internal();
  // コンストラクタへのアクセスを制限 (デフォルトのコンストラクタをプライベート化)
  ExpenseRepository._internal();
  // インスタンスのキャッシュを返すメソッド
  factory ExpenseRepository() {
    return _instance;
  }

  static Database? _database;
  static Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantate the db the first time it is accessed
    _database = await _connectToDatabase();
    return _database!;
  }

  static Future<String> get databasePath async {
    String dbPath = await getDatabasesPath();
    String dbName = 'dev1.db';
    return join(dbPath, dbName);
  }

  static Future<Database> _connectToDatabase() async {
    final String dbPath = await databasePath;
    return openDatabase(
      dbPath,
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

  static Future deleteCurrentDB() async {
    deleteDatabase(await databasePath);
  }

  static Future<Expense> insertExpense(Expense expense) async {
    final db = await database;
    int id = await db.insert('expense', expense.toMap());
    expense.id = id;

    return expense;
  }

  static Future<Expense> findExpenseByID(int id) async {
    final db = await database;
    List<Map<String, Object?>> records = await db.query(
      'expense',
      where: 'id = ?',
      whereArgs: [id],
    );

    Map<String, Object?> mapRead = records.first;
    final Expense expense = Expense.fromMap(mapRead);
    expense.id = id;

    return expense;
  }

  // `year` / `month` に作成された記録の名前を取得し、
  // 金額で降順にソートして返す。
  static Future<List<String>> expenseNames(int year, int month) async {
    final summaries = await getExpenseSummaries(year, month);

    // 金額順で昇順にソート
    summaries.sort((a, b) => b.amount.compareTo(a.amount));
    final names = summaries.map((e) => e.name).toList();

    return names;
  }

  // 過去 `days` 日間に作成された記録のうち、
  // 名前が `name` に一致する記録を返す。
  static Future<List<Expense>> findByNameInPastDays(
      String name, int days) async {
    final db = await database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> results = await db.query(
      'expense',
      where: 'name = ? AND day >= ?',
      whereArgs: [name, now.day - days],
    );

    final expenses = results.map((e) => Expense.fromMap(e)).toList();

    return expenses;
  }

  // `year` / `month に作成された記録のうち、
  // 名前が `name` に一致する記録の金額を昇順にソートして返す。
  // ただし、重複は削除する。
  static Future<List<int>> amountsByYearMonthName(
      int year, int month, String name) async {
    final db = await database;
    final List<Map<String, dynamic>> expenses = await db.query(
      'expense',
      where: 'year = ? AND month = ? AND name = ?',
      whereArgs: [year, month, name],
    );

    // 重複のないリスト
    final amounts = expenses.map((e) => e['amount'] as int).toSet().toList();

    // 降順
    amounts.sort((a, b) => b.compareTo(a));

    return amounts;
  }

  // `year` / `month` に作成された記録を名前別に集計して返す。
  static Future<List<ExpenseSummary>> getExpenseSummaries(
      int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> expenses = await db.query(
      'expense',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );

    // 名前別に集計
    final Map<String, ExpenseSummary> summaryMap = {};
    for (var expense in expenses) {
      ExpenseSummary? summary = summaryMap[expense['name']];
      if (summary == null) {
        summaryMap[expense['name']] = ExpenseSummary(
          expense['name'],
          expense['amount'],
          expense['year'],
          expense['month'],
        );
      } else {
        summary.amount += expense['amount'] as int;
        summary.recurring = true;
      }
    }

    return summaryMap.values.toList();
  }
}
