import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_data.dart';
import '../providers/expense_data_provider.dart' as provider;
import '../providers/store_provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rentController = TextEditingController();
  final _utilitiesController = TextEditingController();
  final _laborController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _otherController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '임대료';
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    _loadLatestExpenseData();
  }

  void _loadLatestExpenseData() {
    final expenseDataProvider =
        Provider.of<provider.ExpenseDataProvider>(context, listen: false);
    final latestData = expenseDataProvider.latestExpenseData;
    if (latestData != null) {
      setState(() {
        _rentController.text = latestData.rent.toString();
        _utilitiesController.text = latestData.utilities.toString();
        _laborController.text = latestData.labor.toString();
        _ingredientsController.text = latestData.ingredients.toString();
        _otherController.text = latestData.other.toString();
        _memoController.text = latestData.memo;
        _selectedDate = latestData.date;
        _selectedCategory = latestData.category;
        _isRecurring = latestData.isRecurring;
      });
    }
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
        _loadLatestExpenseData();
      });
    }
  }

  void _saveExpenseData() {
    if (_formKey.currentState!.validate()) {
      final expenseData = ExpenseData(
        rent: int.tryParse(_rentController.text.replaceAll(',', '')) ?? 0,
        utilities:
            int.tryParse(_utilitiesController.text.replaceAll(',', '')) ?? 0,
        labor: int.tryParse(_laborController.text.replaceAll(',', '')) ?? 0,
        ingredients:
            int.tryParse(_ingredientsController.text.replaceAll(',', '')) ?? 0,
        other: int.tryParse(_otherController.text.replaceAll(',', '')) ?? 0,
        memo: _memoController.text,
        date: _selectedDate,
        category: _selectedCategory,
        amount: (int.tryParse(_rentController.text.replaceAll(',', '')) ?? 0) +
            (int.tryParse(_utilitiesController.text.replaceAll(',', '')) ?? 0) +
            (int.tryParse(_laborController.text.replaceAll(',', '')) ?? 0) +
            (int.tryParse(_ingredientsController.text.replaceAll(',', '')) ??
                0) +
            (int.tryParse(_otherController.text.replaceAll(',', '')) ?? 0),
        isRecurring: _isRecurring,
      );

      context.read<provider.ExpenseDataProvider>().addExpenseData(expenseData);

      // 저장 완료 후 홈 화면으로 이동
      Navigator.pop(context);

      // 저장 완료 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지출이 저장되었습니다.'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지출 등록'),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 선택된 매장명 표시
                Consumer<StoreProvider>(
                  builder: (context, storeProvider, child) {
                    return Text(
                      storeProvider.selectedStore?.name ?? '매장을 선택하세요',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F51B5),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // 날짜 선택
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: Color(0xFF3F51B5)),
                    title: Text(
                      DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(height: 16),
                // 지출 입력
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '지출 내역',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 카테고리 선택
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: '카테고리',
                            border: UnderlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: '임대료', child: Text('임대료')),
                            DropdownMenuItem(value: '공과금', child: Text('공과금')),
                            DropdownMenuItem(value: '인건비', child: Text('인건비')),
                            DropdownMenuItem(value: '식자재', child: Text('식자재')),
                            DropdownMenuItem(value: '기타', child: Text('기타')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // 금액 입력
                        TextFormField(
                          controller: _rentController,
                          decoration: const InputDecoration(
                            labelText: '임대료',
                            border: UnderlineInputBorder(),
                            prefixText: '₩',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandsSeparatorInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '임대료를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _utilitiesController,
                          decoration: const InputDecoration(
                            labelText: '공과금',
                            border: UnderlineInputBorder(),
                            prefixText: '₩',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandsSeparatorInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '공과금을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _laborController,
                          decoration: const InputDecoration(
                            labelText: '인건비',
                            border: UnderlineInputBorder(),
                            prefixText: '₩',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandsSeparatorInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '인건비를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _ingredientsController,
                          decoration: const InputDecoration(
                            labelText: '식자재',
                            border: UnderlineInputBorder(),
                            prefixText: '₩',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandsSeparatorInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '식자재 비용을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _otherController,
                          decoration: const InputDecoration(
                            labelText: '기타',
                            border: UnderlineInputBorder(),
                            prefixText: '₩',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandsSeparatorInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '기타 비용을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _memoController,
                          decoration: const InputDecoration(
                            labelText: '메모',
                            border: UnderlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        // 반복 지출 여부
                        SwitchListTile(
                          title: const Text('반복 지출'),
                          value: _isRecurring,
                          onChanged: (value) {
                            setState(() {
                              _isRecurring = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveExpenseData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '지출 등록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ',';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (!RegExp(r'^\d+$').hasMatch(newValue.text)) {
      return oldValue;
    }

    final value = newValue.text;

    if (value.length < 4) {
      return newValue;
    }

    final chars = value.split('').reversed.toList();
    final newString = <String>[];

    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        newString.add(separator);
      }
      newString.add(chars[i]);
    }

    return TextEditingValue(
      text: newString.reversed.join(),
      selection: TextSelection.collapsed(
        offset: newString.length,
      ),
    );
  }
}
