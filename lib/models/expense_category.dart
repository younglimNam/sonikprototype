import 'package:flutter/material.dart';
import 'expense.dart';

class ExpenseCategory {
  final String name;
  final List<ExpenseSubCategory> subCategories;

  ExpenseCategory({
    required this.name,
    required this.subCategories,
  });

  int getTotalExpenseForDate(DateTime date) {
    return subCategories.fold(
      0,
      (total, subCategory) => total + subCategory.getTotalExpenseForDate(date),
    );
  }
}

class ExpenseSubCategory {
  final String name;
  final List<Expense> expenses;

  ExpenseSubCategory({
    required this.name,
    List<Expense>? expenses,
  }) : expenses = expenses ?? [];

  int getTotalExpenseForDate(DateTime date) {
    return expenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day)
        .fold(0, (total, expense) => total + expense.amount);
  }
}
