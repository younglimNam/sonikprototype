class Expense {
  final String id;
  final DateTime date;
  final String category;
  final String subCategory;
  final int amount;
  final String name;

  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.subCategory,
    required this.amount,
    required this.name,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      amount: map['amount'] ?? 0,
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'category': category,
      'subCategory': subCategory,
      'amount': amount,
      'name': name,
    };
  }
}
