import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseRegisterScreen extends StatefulWidget {
  const ExpenseRegisterScreen({super.key});

  @override
  State<ExpenseRegisterScreen> createState() => _ExpenseRegisterScreenState();
}

class _ExpenseRegisterScreenState extends State<ExpenseRegisterScreen> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  DateTime selectedDate = DateTime.now();

  // 변동 지출 항목 데이터
  final Map<String, Map<String, int>> variableExpenses = {
    '재료비': {
      '식자재': 800000,
      '공산품': 300000,
      '기타 식재료': 150000,
    },
    '배달비': {
      '배달의민족': 300000,
      '쿠팡이츠': 150000,
      '요기요': 120000,
      '기타 플랫폼': 70000,
    },
    '유지/보수비': {
      '소모품': 200000,
      '청소 용역비': 100000,
      '수리비': 100000,
    },
    '기타 변동비': {
      '직원 식사비': 120000,
      '교통비': 100000,
      '출장비': 50000,
      '잡비': 50000,
    }
  };

  // 고정 지출 항목 데이터
  final Map<String, List<Map<String, dynamic>>> fixedExpenses = {
    '정직원 급여': [
      {'date': '2025.04.12', 'name': '김철수', 'amount': 2300000},
      {'date': '2025.04.10', 'name': '박민수', 'amount': 2000000},
    ],
    '아르바이트 급여': [
      {'date': '2025.04.11', 'name': '이지은', 'amount': 850000},
      {'date': '2025.04.09', 'name': '최민기', 'amount': 850000},
    ],
    '보너스': [
      {'date': '2025.04.07', 'name': '이승기', 'amount': 500000},
    ],
    '퇴직금': [
      {'date': '2025.04.05', 'name': '박서준', 'amount': 1200000},
    ],
    '임대료 및 공과금': [
      {'name': '건물 월세', 'amount': 1000000},
      {'name': '전기/수도/가스', 'amount': 200000},
      {'name': '통신비/관리비', 'amount': 150000},
    ],
    '고정 운영비': [
      {'name': '세무 수수료', 'amount': 200000},
      {'name': '보험료', 'amount': 150000},
      {'name': 'POS 유지비', 'amount': 150000},
    ],
    '마케팅 및 홍보비': [
      {'name': '광고비', 'amount': 350000},
      {'name': '인쇄물 제작비', 'amount': 150000},
    ],
  };

  final Map<String, bool> variableExpanded = {};
  final Map<String, bool> fixedExpanded = {};

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  int _calculateTotalExpense() {
    int total = 0;
    // 변동 지출 합계
    for (var category in variableExpenses.values) {
      total += category.values.fold(0, (sum, amount) => sum + amount);
    }
    // 고정 지출 합계
    for (var category in fixedExpenses.values) {
      for (var item in category) {
        total += item['amount'] as int;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalExpense = _calculateTotalExpense();
    final avgDailyExpense = (totalExpense / 30).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '지출 등록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 요약 정보
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy.MM.dd').format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '하루 평균: ${currencyFormatter.format(avgDailyExpense)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '이번달 총 지출',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  currencyFormatter.format(totalExpense),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 변동 지출 항목
                  const Text(
                    '변동 지출 항목',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildVariableExpenseCards(),
                  const SizedBox(height: 24),

                  // 고정 지출 항목
                  const Text(
                    '고정 지출 항목',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildFixedExpenseCards(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.home, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 지출 데이터 저장 로직
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('지출이 등록되었습니다')),
                    );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('지출 등록', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVariableExpenseCards() {
    return variableExpenses.entries.map((entry) {
      final category = entry.key;
      final items = entry.value;
      final isExpanded = variableExpanded[category] ?? false;
      final total = items.values.fold(0, (sum, amount) => sum + amount);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                currencyFormatter.format(total),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => variableExpanded[category] = expanded);
          },
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items.entries.elementAt(index);
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: index != items.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 0.5,
                            ),
                          )
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      item.key,
                      style: const TextStyle(fontSize: 15),
                    ),
                    trailing: Text(
                      currencyFormatter.format(item.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildFixedExpenseCards() {
    return fixedExpenses.entries.map((entry) {
      final category = entry.key;
      final items = entry.value;
      final isExpanded = fixedExpanded[category] ?? false;
      final total = items.fold(0, (sum, item) => sum + (item['amount'] as int));

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                currencyFormatter.format(total),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => fixedExpanded[category] = expanded);
          },
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: index != items.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 0.5,
                            ),
                          )
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      item.containsKey('date')
                          ? '${item['date']} | ${item['name']}'
                          : item['name'],
                      style: const TextStyle(fontSize: 15),
                    ),
                    trailing: Text(
                      currencyFormatter.format(item['amount']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).toList();
  }
}
