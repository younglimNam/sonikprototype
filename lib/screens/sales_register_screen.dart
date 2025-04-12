import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesRegisterScreen extends StatefulWidget {
  const SalesRegisterScreen({super.key});

  @override
  State<SalesRegisterScreen> createState() => _SalesRegisterScreenState();
}

class _SalesRegisterScreenState extends State<SalesRegisterScreen> {
  final currencyFormatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  DateTime selectedDate = DateTime.now();

  // 매출 입력 컨트롤러들
  final cashSalesController = TextEditingController();
  final cardSalesController = TextEditingController();

  // 기본 배달 플랫폼 컨트롤러들
  final Map<String, TextEditingController> deliveryControllers = {
    '배달의민족': TextEditingController(),
    '쿠팡이츠': TextEditingController(),
    '요기요': TextEditingController(),
    '기타': TextEditingController(),
  };

  // 추가 배달 플랫폼
  final List<Map<String, TextEditingController>> additionalPlatforms = [];

  // 목표 매출 (나중에 지출 등록에서 가져올 값)
  final int dailyTargetSales = 680000;
  final int monthlyTargetSales = 20400000;

  @override
  void dispose() {
    cashSalesController.dispose();
    cardSalesController.dispose();
    deliveryControllers.values.forEach((controller) => controller.dispose());
    additionalPlatforms.forEach((platform) {
      platform['name']?.dispose();
      platform['amount']?.dispose();
    });
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addNewPlatform() {
    setState(() {
      additionalPlatforms.add({
        'name': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removePlatform(int index) {
    setState(() {
      final platform = additionalPlatforms.removeAt(index);
      platform['name']?.dispose();
      platform['amount']?.dispose();
    });
  }

  int get totalSales {
    int total = 0;
    try {
      total +=
          int.parse(cashSalesController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (_) {}
    try {
      total +=
          int.parse(cardSalesController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (_) {}

    for (var controller in deliveryControllers.values) {
      try {
        total += int.parse(controller.text.replaceAll(RegExp(r'[^0-9]'), ''));
      } catch (_) {}
    }

    for (var platform in additionalPlatforms) {
      try {
        total += int.parse(
            platform['amount']!.text.replaceAll(RegExp(r'[^0-9]'), ''));
      } catch (_) {}
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매출 등록'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 날짜 선택
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📅 ${DateFormat('yyyy.MM.dd').format(selectedDate)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('날짜 선택'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 매출 요약 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 매출 요약 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('🧮 오늘 총 매출:', totalSales),
                    _buildSummaryRow('🎯 오늘 목표 매출:', dailyTargetSales),
                    _buildSummaryRow('📆 이번달 목표 매출:', monthlyTargetSales),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // POS 매출 입력
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📦 POS 매출 입력',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAmountField('현금 매출:', cashSalesController),
                    const SizedBox(height: 8),
                    _buildAmountField('카드 매출:', cardSalesController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 배달 매출 입력
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📦 배달 매출 입력',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...deliveryControllers.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildAmountField(e.key + ':', e.value),
                      ),
                    ),
                    if (additionalPlatforms.isNotEmpty) const Divider(),
                    ...additionalPlatforms.asMap().entries.map(
                          (entry) => _buildAdditionalPlatformField(
                            entry.key,
                            entry.value,
                          ),
                        ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addNewPlatform,
                      icon: const Icon(Icons.add),
                      label: const Text('배달 플랫폼 추가'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                    // TODO: 매출 데이터 저장 로직 (Firebase 연동 시 구현)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('매출이 등록되었습니다')),
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
                  child: const Text('매출 등록', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            currencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: label.contains('총 매출')
                  ? (amount >= dailyTargetSales ? Colors.green : Colors.red)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0',
              prefixText: '₩ ',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalPlatformField(
    int index,
    Map<String, TextEditingController> platform,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: platform['name'],
              decoration: const InputDecoration(
                hintText: '플랫폼명',
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: platform['amount'],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                prefixText: '₩ ',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removePlatform(index),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}
