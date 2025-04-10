import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/expense_data.dart';
import '../models/sales_data.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '식재료';
  bool _isRecurring = false;
  int _editingIndex = -1;

  final List<String> _categories = [
    '식재료',
    '인건비',
    '임대료',
    '공과금',
    '마케팅',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _categoryController.text = _selectedCategory;
    _loadLatestSalesData();
  }

  void _loadLatestSalesData() {
    final salesDataProvider =
        Provider.of<SalesDataProvider>(context, listen: false);
    final latestData = salesDataProvider.latestSalesData;

    if (latestData != null) {
      setState(() {
        _selectedDate = latestData.date;
      });
    }
  }

  String _formatAmount(int amount) {
    return '₩${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpenseData() {
    if (_formKey.currentState!.validate()) {
      final amount = int.tryParse(
              _amountController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
          0;

      final expenseData = ExpenseData(
        amount: amount,
        category: _selectedCategory,
        memo: _memoController.text,
        date: _selectedDate,
        isRecurring: _isRecurring,
      );

      final expenseDataProvider =
          Provider.of<ExpenseDataProvider>(context, listen: false);

      if (_editingIndex >= 0) {
        expenseDataProvider.updateExpense(_editingIndex, expenseData);
      } else {
        expenseDataProvider.addExpense(expenseData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지출 데이터가 저장되었습니다.')),
      );

      Navigator.pop(context);
    }
  }

  void _editExpense(int index, ExpenseData expense) {
    setState(() {
      _editingIndex = index;
      _amountController.text = expense.amount.toString();
      _selectedCategory = expense.category;
      _categoryController.text = expense.category;
      _memoController.text = expense.memo;
      _selectedDate = expense.date;
      _isRecurring = expense.isRecurring;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseDataProvider = Provider.of<ExpenseDataProvider>(context);
    final salesDataProvider = Provider.of<SalesDataProvider>(context);
    final latestSalesData = salesDataProvider.latestSalesData;

    final todayExpenses =
        expenseDataProvider.getTotalExpensesForDate(_selectedDate);
    final todaySales = latestSalesData?.total ?? 0;
    final todayProfit = todaySales - todayExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('지출 등록'),
      ),
      body: Column(
        children: [
          // 오늘의 매출 및 지출 요약
          if (latestSalesData != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('오늘 매출:'),
                        Text(
                          _formatAmount(todaySales),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('오늘 지출:'),
                        Text(
                          _formatAmount(todayExpenses),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('오늘 손익:'),
                        Text(
                          _formatAmount(todayProfit),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: todayProfit >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 지출 등록 폼
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    _buildCategorySelector(),
                    const SizedBox(height: 24),
                    _buildAmountInput(),
                    const SizedBox(height: 24),
                    _buildMemoInput(),
                    const SizedBox(height: 24),
                    _buildRecurringSwitch(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),

          // 지출 목록
          if (expenseDataProvider.expenses.isNotEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '등록된 지출',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: expenseDataProvider.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenseDataProvider.expenses[index];
                        return ListTile(
                          title: Text(
                              '${expense.category} - ${_formatAmount(expense.amount)}'),
                          subtitle: Text(expense.memo),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editExpense(index, expense),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: ListTile(
        title: const Text('날짜 선택'),
        subtitle: Text(
          '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
                _categoryController.text = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '금액',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixText: '원',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsSeparatorInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '금액을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMemoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '메모',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _memoController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '지출 내용을 입력해주세요',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRecurringSwitch() {
    return SwitchListTile(
      title: const Text('정기 지출'),
      subtitle: const Text('매월 반복되는 지출인 경우 선택'),
      value: _isRecurring,
      onChanged: (bool value) {
        setState(() {
          _isRecurring = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveExpenseData,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(_editingIndex >= 0 ? '수정하기' : '저장하기'),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int value = int.parse(newValue.text.replaceAll(',', ''));
    final String formatted = value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
