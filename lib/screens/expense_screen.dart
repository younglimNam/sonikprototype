import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_data_provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import 'utility_bills_screen.dart';
import 'package:intl/intl.dart';
import 'package:sonik_app/screens/labor_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<String>> _categories = {
    '인건비': ['정직원 급여', '아르바이트 급여', '보너스', '퇴직금'],
    '재료비': ['식자재', '공산품', '기타'],
    '배달비': ['배달의민족', '쿠팡이츠', '요기요', '기타 플랫폼', '할인 프로모션'],
    '임대료 및 공과금': ['건물 월세', '전기/수도/가스 요금', '통신비 / 인터넷 / 관리비'],
    '마케팅 및 홍보비': ['광고비', '인쇄물 제작비'],
    '설비 및 유지비': ['수리/교체비', '청소 용역비', '소모품'],
    '운영/관리비': ['세무/회계 수수료', '카드 수수료', '보험료', 'POS 유지비'],
    '기타 운영비': ['직원 식사비', '교통비', '잡비', '출장비'],
  };

  final Map<String, bool> _isExpanded = {};
  final Map<String, TextEditingController> _amountControllers = {};
  final Map<String, String> _amounts = {};
  final ScrollController _scrollController = ScrollController();
  final List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExpenseData();
  }

  void _initializeControllers() {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    for (var category in expenseProvider.expenseCategories) {
      _isExpanded[category.name] = false;
      for (var subCategory in category.subCategories) {
        _amountControllers[subCategory.name] = TextEditingController();
      }
    }
  }

  Future<void> _loadExpenseData() async {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    await expenseProvider.loadExpenses();
    final expenses = expenseProvider.getExpensesForDate(_selectedDate);
    _registeredExpenses.clear();
    _registeredExpenses.addAll(expenses);

    for (var expense in expenses) {
      _amountControllers[expense.subCategory]?.text = expense.amount.toString();
    }
  }

  Future<void> _saveExpenses() async {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    expenseProvider.clearExpensesForDate(_selectedDate);

    for (var category in expenseProvider.expenseCategories) {
      for (var subCategory in category.subCategories) {
        final amount =
            int.tryParse(_amountControllers[subCategory.name]?.text ?? '0') ??
                0;
        if (amount > 0) {
          final expense = Expense(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            date: _selectedDate,
            category: category.name,
            subCategory: subCategory.name,
            amount: amount,
            name: subCategory.name,
          );
          expenseProvider.addExpense(expense);
          _registeredExpenses.add(expense);
        }
      }
    }

    setState(() {});
  }

  void _deleteExpense(Expense expense) {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    expenseProvider.deleteExpense(expense);
    _registeredExpenses.remove(expense);
    setState(() {});
  }

  void _editExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${expense.category} - ${expense.subCategory} 수정'),
        content: TextField(
          controller: TextEditingController(text: expense.amount.toString()),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '금액',
            suffixText: '원',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final newAmount = int.tryParse(TextEditingController().text) ?? 0;
              if (newAmount > 0) {
                final updatedExpense = Expense(
                  id: expense.id,
                  date: expense.date,
                  category: expense.category,
                  subCategory: expense.subCategory,
                  amount: newAmount,
                  name: expense.name,
                );
                final expenseProvider =
                    Provider.of<ExpenseDataProvider>(context, listen: false);
                expenseProvider.updateExpense(updatedExpense);
                _registeredExpenses[_registeredExpenses.indexOf(expense)] =
                    updatedExpense;
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(String categoryName) {
    final TextEditingController newItemController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 항목 추가'),
        content: TextField(
          controller: newItemController,
          decoration: const InputDecoration(
            hintText: '항목 이름을 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (newItemController.text.isNotEmpty) {
                final expenseProvider =
                    Provider.of<ExpenseDataProvider>(context, listen: false);
                expenseProvider.addSubCategory(
                    categoryName, newItemController.text);
                _amountControllers[newItemController.text] =
                    TextEditingController();
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF424242),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _loadExpenseData();
    }
  }

  double _getTotalExpense() {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    final totalExpense = expenseProvider.getTotalExpensesForDate(_selectedDate);
    final salaryExpenses = expenseProvider
        .getExpensesForDate(_selectedDate)
        .where((expense) =>
            expense.category == '인건비' && expense.subCategory == '급여')
        .fold(0, (sum, expense) => sum + expense.amount);
    return (totalExpense - salaryExpenses).toDouble();
  }

  double _getMonthlyExpense() {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    double total = 0;
    for (var date = firstDayOfMonth;
        date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final dailyExpense = expenseProvider.getTotalExpensesForDate(date);
      final salaryExpenses = expenseProvider
          .getExpensesForDate(date)
          .where((expense) =>
              expense.category == '인건비' && expense.subCategory == '급여')
          .fold(0, (sum, expense) => sum + expense.amount);
      total += (dailyExpense - salaryExpenses);
    }
    return total;
  }

  void _onLaborExpenseSelected() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LaborExpenseScreen(
          category: '인건비',
          subCategory: '정직원 급여',
        ),
      ),
    ).then((_) {
      _loadExpenseData(); // 인건비 등록 후 리스트 새로고침
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '지출등록',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF34495E).withOpacity(0.1),
                  const Color(0xFF2C3E50).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('날짜선택'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2C3E50),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF34495E).withOpacity(0.1),
                                const Color(0xFF2C3E50).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '오늘의 총 지출: ${_getTotalExpense().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF34495E).withOpacity(0.1),
                                const Color(0xFF2C3E50).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${DateFormat('yyyy년 MM월').format(_selectedDate)} 누적 지출: ${_getMonthlyExpense().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '지출 항목',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Consumer<ExpenseDataProvider>(
                      builder: (context, expenseProvider, child) {
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: expenseProvider.expenseCategories.length,
                          itemBuilder: (context, index) {
                            final category =
                                expenseProvider.expenseCategories[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    const Color(0xFFF8F9FA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.05),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          _isExpanded[category.name] =
                                              !(_isExpanded[category.name] ??
                                                  false);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              const Color(0xFFF8F9FA),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${index + 1}.',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        category.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xFF2C3E50),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.add,
                                                            size: 20),
                                                        onPressed: () =>
                                                            _showAddItemDialog(
                                                                category.name),
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(),
                                                        color: const Color(
                                                            0xFF2C3E50),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '₩${category.subCategories.fold<int>(0, (sum, subCat) {
                                                    if (category.name ==
                                                            '인건비' &&
                                                        subCat.name ==
                                                            '정직원 급여') {
                                                      return sum +
                                                          Provider.of<ExpenseDataProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .getExpensesForDate(
                                                                  _selectedDate)
                                                              .where((expense) =>
                                                                  expense.category ==
                                                                      '인건비' &&
                                                                  expense.subCategory ==
                                                                      '정직원 급여')
                                                              .fold<int>(
                                                                  0,
                                                                  (subSum,
                                                                          expense) =>
                                                                      subSum +
                                                                      expense
                                                                          .amount);
                                                    } else {
                                                      return sum +
                                                          (int.tryParse(_amountControllers[
                                                                          subCat
                                                                              .name]
                                                                      ?.text ??
                                                                  '0') ??
                                                              0);
                                                    }
                                                  }).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isExpanded[category.name] ?? false)
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFFF8F9FA),
                                            Colors.white,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: category.subCategories
                                            .map((subCategory) {
                                          final amount = int.tryParse(
                                                  _amountControllers[
                                                              subCategory.name]
                                                          ?.text ??
                                                      '0') ??
                                              0;
                                          final totalExpense = subCategory
                                              .getTotalExpenseForDate(
                                                  _selectedDate);
                                          final salaryExpenses = Provider.of<
                                                  ExpenseDataProvider>(context)
                                              .getExpensesForDate(_selectedDate)
                                              .where((expense) =>
                                                  expense.category == '인건비' &&
                                                  expense.subCategory == '급여')
                                              .fold(
                                                  0,
                                                  (sum, expense) =>
                                                      sum + expense.amount);

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        subCategory.name,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF2C3E50),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      if ((category.name ==
                                                                  '인건비' &&
                                                              subCategory
                                                                      .name ==
                                                                  '정직원 급여') ||
                                                          (category.name ==
                                                                  '인건비' &&
                                                              subCategory
                                                                      .name ==
                                                                  '아르바이트 급여') ||
                                                          (category.name ==
                                                                  '인건비' &&
                                                              subCategory
                                                                      .name ==
                                                                  '보너스') ||
                                                          (category.name ==
                                                                  '인건비' &&
                                                              subCategory
                                                                      .name ==
                                                                  '퇴직금'))
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.add,
                                                              size: 20),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LaborExpenseScreen(
                                                                  category:
                                                                      category
                                                                          .name,
                                                                  subCategory:
                                                                      subCategory
                                                                          .name,
                                                                ),
                                                              ),
                                                            ).then((_) =>
                                                                _loadExpenseData());
                                                          },
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                          color: const Color(
                                                              0xFF2C3E50),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        const Color(0xFF27AE60)
                                                            .withOpacity(0.1),
                                                        const Color(0xFF2ECC71)
                                                            .withOpacity(0.05),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    category.name == '인건비' &&
                                                            (subCategory.name ==
                                                                    '정직원 급여' ||
                                                                subCategory
                                                                        .name ==
                                                                    '아르바이트 급여' ||
                                                                subCategory
                                                                        .name ==
                                                                    '보너스' ||
                                                                subCategory
                                                                        .name ==
                                                                    '퇴직금')
                                                        ? '${Provider.of<ExpenseDataProvider>(context, listen: false).getExpensesForDate(_selectedDate).where((expense) => expense.category == '인건비' && expense.subCategory == subCategory.name).fold<int>(0, (sum, expense) => sum + expense.amount).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
                                                        : '${(int.tryParse(_amountControllers[subCategory.name]?.text ?? '0') ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF2C3E50),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saveExpenses,
                icon: const Icon(Icons.save, size: 20),
                label: const Text(
                  '지출등록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color(0xFF2C3E50),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
