import 'package:flutter/foundation.dart';
import 'package:sonik_app/models/expense.dart';
import 'package:sonik_app/models/labor_expense.dart';
import 'package:sonik_app/models/expense_category.dart';
import 'package:sonik_app/database/database_helper.dart';
import 'package:intl/intl.dart';

class ExpenseDataProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  final List<LaborExpense> _laborExpenses = [];
  final List<ExpenseCategory> _expenseCategories = [
    ExpenseCategory(
      name: '인건비',
      subCategories: [
        ExpenseSubCategory(name: '정직원 급여'),
        ExpenseSubCategory(name: '아르바이트 급여'),
        ExpenseSubCategory(name: '보너스'),
        ExpenseSubCategory(name: '퇴직금'),
      ],
    ),
    ExpenseCategory(
      name: '재료비',
      subCategories: [
        ExpenseSubCategory(name: '식자재'),
        ExpenseSubCategory(name: '공산품'),
        ExpenseSubCategory(name: '기타'),
      ],
    ),
    ExpenseCategory(
      name: '배달비',
      subCategories: [
        ExpenseSubCategory(name: '배달의민족'),
        ExpenseSubCategory(name: '쿠팡이츠'),
        ExpenseSubCategory(name: '요기요'),
        ExpenseSubCategory(name: '기타 플랫폼'),
        ExpenseSubCategory(name: '할인 프로모션'),
      ],
    ),
    ExpenseCategory(
      name: '임대료 및 공과금',
      subCategories: [
        ExpenseSubCategory(name: '건물 월세'),
        ExpenseSubCategory(name: '전기/수도/가스 요금'),
        ExpenseSubCategory(name: '통신비 / 인터넷 / 관리비'),
      ],
    ),
    ExpenseCategory(
      name: '마케팅 및 홍보비',
      subCategories: [
        ExpenseSubCategory(name: '광고비'),
        ExpenseSubCategory(name: '인쇄물 제작비'),
      ],
    ),
    ExpenseCategory(
      name: '설비 및 유지비',
      subCategories: [
        ExpenseSubCategory(name: '수리/교체비'),
        ExpenseSubCategory(name: '청소 용역비'),
        ExpenseSubCategory(name: '소모품'),
      ],
    ),
    ExpenseCategory(
      name: '운영/관리비',
      subCategories: [
        ExpenseSubCategory(name: '세무/회계 수수료'),
        ExpenseSubCategory(name: '카드 수수료'),
        ExpenseSubCategory(name: '보험료'),
        ExpenseSubCategory(name: 'POS 유지비'),
      ],
    ),
    ExpenseCategory(
      name: '기타 운영비',
      subCategories: [
        ExpenseSubCategory(name: '직원 식사비'),
        ExpenseSubCategory(name: '교통비'),
        ExpenseSubCategory(name: '잡비'),
        ExpenseSubCategory(name: '출장비'),
      ],
    ),
  ];

  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Expense> get expenses => _expenses;
  List<LaborExpense> get laborExpenses => _laborExpenses;
  List<ExpenseCategory> get expenseCategories => _expenseCategories;

  Future<void> loadExpenses() async {
    final expenses = await _dbHelper.getExpenses();
    _expenses.clear();
    _expenses.addAll(expenses.map((e) => Expense.fromMap(e)));
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense.toMap());
    _expenses.add(expense);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.updateExpense(expense.toMap());
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
    notifyListeners();
  }

  Future<void> deleteExpense(Expense expense) async {
    await _dbHelper.deleteExpense(expense.id);
    _expenses.removeWhere((e) => e.id == expense.id);
    notifyListeners();
  }

  void addLaborExpense(LaborExpense expense) {
    _laborExpenses.add(expense);
    notifyListeners();
  }

  void updateLaborExpense(LaborExpense expense) {
    final index = _laborExpenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _laborExpenses[index] = expense;
      notifyListeners();
    }
  }

  void deleteLaborExpense(String id) {
    _laborExpenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  Future<void> clearExpensesForDate(DateTime date) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    await _dbHelper.clearExpensesForDate(dateString);
    _expenses.removeWhere(
        (e) => DateFormat('yyyy-MM-dd').format(e.date) == dateString);
    notifyListeners();
  }

  List<Expense> getExpensesForDate(DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return _expenses
        .where((e) => DateFormat('yyyy-MM-dd').format(e.date) == dateString)
        .toList();
  }

  int getTotalExpensesForDate(DateTime date) {
    return getExpensesForDate(date)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  int getTotalExpensesForDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  int getTotalLaborExpensesForDate(DateTime date) {
    return _laborExpenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day)
        .fold(0, (sum, expense) => sum + expense.salary);
  }

  List<LaborExpense> getLaborExpensesForDate(DateTime date) {
    return _laborExpenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day)
        .toList();
  }

  void addSubCategory(String categoryName, String subCategoryName) {
    final category =
        _expenseCategories.firstWhere((c) => c.name == categoryName);
    category.subCategories.add(ExpenseSubCategory(name: subCategoryName));
    notifyListeners();
  }
}
