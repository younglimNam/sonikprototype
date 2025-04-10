import 'package:flutter/foundation.dart';

class ExpenseData {
  final int rent;
  final int utilities;
  final int labor;
  final int ingredients;
  final int other;
  final String memo;
  final DateTime date;
  final String category;
  final int amount;
  final bool isRecurring;

  ExpenseData({
    required this.rent,
    required this.utilities,
    required this.labor,
    required this.ingredients,
    required this.other,
    required this.memo,
    required this.date,
    required this.category,
    required this.amount,
    required this.isRecurring,
  });

  Map<String, dynamic> toMap() {
    return {
      'rent': rent,
      'utilities': utilities,
      'labor': labor,
      'ingredients': ingredients,
      'other': other,
      'memo': memo,
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'isRecurring': isRecurring,
    };
  }

  factory ExpenseData.fromMap(Map<String, dynamic> map) {
    return ExpenseData(
      rent: map['rent'] ?? 0,
      utilities: map['utilities'] ?? 0,
      labor: map['labor'] ?? 0,
      ingredients: map['ingredients'] ?? 0,
      other: map['other'] ?? 0,
      memo: map['memo'] ?? '',
      date: DateTime.parse(map['date']),
      category: map['category'] ?? '',
      amount: map['amount'] ?? 0,
      isRecurring: map['isRecurring'] ?? false,
    );
  }
}

class ExpenseDataProvider extends ChangeNotifier {
  final List<ExpenseData> _expenses = [];
  final List<ExpenseData> _recurringExpenses = [];

  List<ExpenseData> get expenses => _expenses;
  List<ExpenseData> get recurringExpenses => _recurringExpenses;

  void addExpense(ExpenseData expense) {
    _expenses.add(expense);
    if (expense.isRecurring) {
      _recurringExpenses.add(expense);
    }
    notifyListeners();
  }

  void updateExpense(int index, ExpenseData expense) {
    if (index >= 0 && index < _expenses.length) {
      _expenses[index] = expense;

      // 반복 지출 업데이트
      if (expense.isRecurring) {
        final recurringIndex = _recurringExpenses.indexWhere(
            (e) => e.category == expense.category && e.memo == expense.memo);

        if (recurringIndex >= 0) {
          _recurringExpenses[recurringIndex] = expense;
        } else {
          _recurringExpenses.add(expense);
        }
      }

      notifyListeners();
    }
  }

  void removeExpense(int index) {
    if (index >= 0 && index < _expenses.length) {
      final expense = _expenses[index];
      _expenses.removeAt(index);

      // 반복 지출에서도 제거
      if (expense.isRecurring) {
        _recurringExpenses.removeWhere(
            (e) => e.category == expense.category && e.memo == expense.memo);
      }

      notifyListeners();
    }
  }

  int getTotalExpensesForDate(DateTime date) {
    return _expenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day)
        .fold(0, (sum, expense) => sum + expense.amount);
  }
}
