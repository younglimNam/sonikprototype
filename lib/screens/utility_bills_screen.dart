import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_data_provider.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class UtilityBillsScreen extends StatefulWidget {
  const UtilityBillsScreen({Key? key}) : super(key: key);

  @override
  _UtilityBillsScreenState createState() => _UtilityBillsScreenState();
}

class _UtilityBillsScreenState extends State<UtilityBillsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _electricityController = TextEditingController();
  final _waterController = TextEditingController();
  final _gasController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _electricityController.dispose();
    _waterController.dispose();
    _gasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveUtilityBills() {
    if (!_formKey.currentState!.validate()) return;

    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    final totalAmount = (int.tryParse(_electricityController.text) ?? 0) +
        (int.tryParse(_waterController.text) ?? 0) +
        (int.tryParse(_gasController.text) ?? 0);

    expenseProvider.addExpense(
      Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        category: '임대료 및 공과금',
        subCategory: '전기/수도/가스 요금',
        amount: totalAmount,
        name: '전기/수도/가스 요금',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공과금이 저장되었습니다')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '공과금 등록',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _electricityController,
                decoration: InputDecoration(
                  labelText: '전기 요금',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2C3E50)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전기 요금을 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _waterController,
                decoration: InputDecoration(
                  labelText: '수도 요금',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2C3E50)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '수도 요금을 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gasController,
                decoration: InputDecoration(
                  labelText: '가스 요금',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2C3E50)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '가스 요금을 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveUtilityBills,
                icon: const Icon(Icons.save),
                label: const Text('저장'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
