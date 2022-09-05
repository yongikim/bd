class Expense {
  int? id;
  final String name;
  final int amount;
  final int year;
  final int month;
  final int day;

  Expense(
    this.name,
    this.amount,
    this.year,
    this.month,
    this.day,
  );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'year': year,
      'month': month,
      'day': day,
    };
  }

  static Expense fromMap(Map<String, dynamic> m) {
    return Expense(
      m['name'],
      m['amount'],
      m['year'],
      m['year'],
      m['day'],
    );
  }
}
