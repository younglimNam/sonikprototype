import 'package:flutter/foundation.dart';
import '../models/expense_data.dart';

class ExpenseDataProvider with ChangeNotifier {
  final List<ExpenseData> _expenseData = [];

  ExpenseData? get latestExpenseData =>
      _expenseData.isNotEmpty ? _expenseData.last : null;

  void addExpenseData(ExpenseData data) {
    _expenseData.add(data);
    notifyListeners();
  }

  int getTotalExpensesForDate(DateTime date) {
    final expenseData = _expenseData.where((data) =>
        data.date.year == date.year &&
        data.date.month == date.month &&
        data.date.day == date.day);

    return expenseData.fold(0, (sum, data) => sum + data.amount);
  }

  int getTotalExpensesForDateRange(DateTime start, DateTime end) {
    final expenseData = _expenseData.where((data) =>
        data.date.isAfter(start.subtract(const Duration(days: 1))) &&
        data.date.isBefore(end.add(const Duration(days: 1))));

    return expenseData.fold(0, (sum, data) => sum + data.amount);
  }
}
