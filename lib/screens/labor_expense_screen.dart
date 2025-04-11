import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_data_provider.dart';
import '../models/expense.dart';
import '../models/labor_expense.dart';
import 'package:intl/intl.dart';

class LaborExpenseScreen extends StatefulWidget {
  final String category;
  final String subCategory;

  const LaborExpenseScreen({
    Key? key,
    required this.category,
    required this.subCategory,
  }) : super(key: key);

  @override
  _LaborExpenseScreenState createState() => _LaborExpenseScreenState();
}

class _LaborExpenseScreenState extends State<LaborExpenseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<Expense> _registeredExpenses = [];
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _loadExpenses() {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    setState(() {
      _registeredExpenses.clear();
      _registeredExpenses.addAll(expenseProvider
          .getExpensesForDate(_selectedDate)
          .where((expense) =>
              expense.category == widget.category &&
              expense.subCategory == widget.subCategory));
    });
  }

  Future<void> _selectDate() async {
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
    }
  }

  void _saveExpense() {
    if (_nameController.text.isNotEmpty && _amountController.text.isNotEmpty) {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        amount: int.parse(_amountController.text),
        date: _selectedDate,
        category: widget.category,
        subCategory: widget.subCategory,
      );

      // 저장 후 즉시 리스트 업데이트
      Provider.of<ExpenseDataProvider>(context, listen: false)
          .addExpense(expense);
      setState(() {
        _registeredExpenses.add(expense);
        _isRegistering = false;
      });

      _nameController.clear();
      _amountController.clear();
    }
  }

  void _editExpense(Expense expense) {
    // Implementation of editExpense method
  }

  void _deleteExpense(Expense expense) {
    // Implementation of deleteExpense method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.subCategory}'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '등록된 ${widget.subCategory}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _registeredExpenses.isEmpty
                  ? Center(
                      child: Text(
                        '등록된 ${widget.subCategory}가 없습니다.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _registeredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = _registeredExpenses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              expense.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.subCategory == '정직원 급여'
                                      ? '입사일: ${DateFormat('yyyy년 MM월 dd일').format(expense.date)}'
                                      : '근무일: ${DateFormat('yyyy년 MM월 dd일').format(expense.date)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                ),
                                Text(
                                  '${expense.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF27AE60),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFF2C3E50)),
                                  onPressed: () => _editExpense(expense),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Color(0xFFE74C3C)),
                                  onPressed: () => _deleteExpense(expense),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            if (!_isRegistering)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isRegistering = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '새로 등록하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            if (_isRegistering) ...[
              TextButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  widget.subCategory == '정직원 급여'
                      ? '입사일: ${DateFormat('yyyy년 MM월 dd일').format(_selectedDate)}'
                      : '근무일: ${DateFormat('yyyy년 MM월 dd일').format(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      widget.subCategory == '정직원 급여' ? '직원 이름' : '아르바이트 이름',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '급여',
                  border: OutlineInputBorder(),
                  suffixText: '원',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isRegistering = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF95A5A6),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
