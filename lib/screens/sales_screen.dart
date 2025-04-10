import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/sales_data.dart';
import '../providers/sales_data_provider.dart' as provider;
import '../providers/store_provider.dart';
import 'package:intl/intl.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  final _cardController = TextEditingController();
  final _otherPosController = TextEditingController();
  final _otherPosNameController = TextEditingController();
  final _baeminController = TextEditingController();
  final _coupangController = TextEditingController();
  final _yogiyoController = TextEditingController();
  final _otherDeliveryController = TextEditingController();
  final _otherDeliveryNameController = TextEditingController();

  int _totalSales = 0;
  int _posTotalSales = 0;
  int _deliveryTotalSales = 0;
  int _otherTotalSales = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _addListeners();
    _loadLatestSalesData();
  }

  void _loadLatestSalesData() {
    final salesDataProvider =
        Provider.of<provider.SalesDataProvider>(context, listen: false);
    final latestData = salesDataProvider.latestSalesData;
    if (latestData != null) {
      setState(() {
        _cashController.text = latestData.cash.toString();
        _cardController.text = latestData.card.toString();
        _otherPosController.text = latestData.otherPos.toString();
        _otherPosNameController.text = latestData.otherPosName;
        _baeminController.text = latestData.baemin.toString();
        _coupangController.text = latestData.coupang.toString();
        _yogiyoController.text = latestData.yogiyo.toString();
        _otherDeliveryController.text = latestData.otherDelivery.toString();
        _otherDeliveryNameController.text = latestData.otherDeliveryName;
        _selectedDate = latestData.date;
        _calculateTotal();
      });
    }
  }

  void _addListeners() {
    _cashController.addListener(_calculateTotal);
    _cardController.addListener(_calculateTotal);
    _otherPosController.addListener(_calculateTotal);
    _baeminController.addListener(_calculateTotal);
    _coupangController.addListener(_calculateTotal);
    _yogiyoController.addListener(_calculateTotal);
    _otherDeliveryController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    setState(() {
      _posTotalSales = _parseAmount(_cashController.text) +
          _parseAmount(_cardController.text);
      _deliveryTotalSales = _parseAmount(_baeminController.text) +
          _parseAmount(_coupangController.text) +
          _parseAmount(_yogiyoController.text);
      _otherTotalSales = _parseAmount(_otherPosController.text) +
          _parseAmount(_otherDeliveryController.text);
      _totalSales = _posTotalSales + _deliveryTotalSales + _otherTotalSales;
    });
  }

  int _parseAmount(String text) {
    return int.tryParse(text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
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
        _loadLatestSalesData();
      });
    }
  }

  void _saveSalesData() {
    if (_formKey.currentState!.validate()) {
      final salesData = SalesData(
        cash: int.tryParse(_cashController.text.replaceAll(',', '')) ?? 0,
        card: int.tryParse(_cardController.text.replaceAll(',', '')) ?? 0,
        baemin: int.tryParse(_baeminController.text.replaceAll(',', '')) ?? 0,
        coupang: int.tryParse(_coupangController.text.replaceAll(',', '')) ?? 0,
        yogiyo: int.tryParse(_yogiyoController.text.replaceAll(',', '')) ?? 0,
        otherDelivery:
            int.tryParse(_otherDeliveryController.text.replaceAll(',', '')) ??
                0,
        otherPos:
            int.tryParse(_otherPosController.text.replaceAll(',', '')) ?? 0,
        otherPosName: _otherPosNameController.text,
        otherDeliveryName: _otherDeliveryNameController.text,
        date: _selectedDate,
      );

      final salesDataProvider =
          Provider.of<provider.SalesDataProvider>(context, listen: false);
      salesDataProvider.addSalesData(salesData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('매출 데이터가 저장되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매출 등록'),
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
                // 총 매출 정보
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
                          '오늘의 매출',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '총 매출:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatAmount(_totalSales),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'POS 매출:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatAmount(_posTotalSales),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '배달 매출:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatAmount(_deliveryTotalSales),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '기타 매출:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatAmount(_otherTotalSales),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // POS 매출 입력
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
                          'POS 매출',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.money, color: Color(0xFF3F51B5)),
                            const SizedBox(width: 8),
                            const Text(
                              '현금 매출:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: _cashController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  suffixText: '₩',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandsSeparatorInputFormatter(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.credit_card,
                                color: Color(0xFF3F51B5)),
                            const SizedBox(width: 8),
                            const Text(
                              '카드 매출:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: _cardController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  suffixText: '₩',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandsSeparatorInputFormatter(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 배달 매출 입력
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
                          '배달 매출',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.delivery_dining,
                                color: Color(0xFF3F51B5)),
                            const SizedBox(width: 8),
                            const Text(
                              '배민:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: _baeminController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  suffixText: '₩',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandsSeparatorInputFormatter(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.local_shipping,
                                color: Color(0xFF3F51B5)),
                            const SizedBox(width: 8),
                            const Text(
                              '쿠팡이츠:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: _coupangController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  suffixText: '₩',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandsSeparatorInputFormatter(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.motorcycle,
                                color: Color(0xFF3F51B5)),
                            const SizedBox(width: 8),
                            const Text(
                              '요기요:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: _yogiyoController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  suffixText: '₩',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandsSeparatorInputFormatter(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.more_horiz,
                                color: Color(0xFF3F51B5)),
                            const SizedBox(width: 8),
                            const Text(
                              '기타:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: _otherDeliveryController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  suffixText: '₩',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandsSeparatorInputFormatter(),
                                ],
                              ),
                            ),
                          ],
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
          onPressed: _saveSalesData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '매출 등록',
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

  @override
  void dispose() {
    _cashController.dispose();
    _cardController.dispose();
    _otherPosController.dispose();
    _otherPosNameController.dispose();
    _baeminController.dispose();
    _coupangController.dispose();
    _yogiyoController.dispose();
    _otherDeliveryController.dispose();
    _otherDeliveryNameController.dispose();
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
