import '../models/expense_data.dart';

class ExpenseService {
  final List<ExpenseData> _expenses = [];

  void addExpense(ExpenseData expense) {
    _expenses.add(expense);
  }

  void updateExpense(int index, ExpenseData expense) {
    if (index >= 0 && index < _expenses.length) {
      _expenses[index] = expense;
    }
  }

  void removeExpense(int index) {
    if (index >= 0 && index < _expenses.length) {
      _expenses.removeAt(index);
    }
  }

  List<ExpenseData> getExpensesForDate(DateTime date) {
    return _expenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day)
        .toList();
  }

  void clearExpensesForDate(DateTime date) {
    _expenses.removeWhere((expense) =>
        expense.date.year == date.year &&
        expense.date.month == date.month &&
        expense.date.day == date.day);
  }

  int getTotalExpensesForDate(DateTime date) {
    return _expenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  int getTotalExpensesForDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .fold(0, (sum, expense) => sum + expense.amount);
  }
}
