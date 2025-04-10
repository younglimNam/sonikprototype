import 'package:flutter/foundation.dart';

class SalesData {
  final int cash;
  final int card;
  final int otherPos;
  final String otherPosName;
  final int baemin;
  final int coupang;
  final int yogiyo;
  final int otherDelivery;
  final String otherDeliveryName;
  final DateTime date;

  SalesData({
    required this.cash,
    required this.card,
    required this.otherPos,
    required this.otherPosName,
    required this.baemin,
    required this.coupang,
    required this.yogiyo,
    required this.otherDelivery,
    required this.otherDeliveryName,
    required this.date,
  });

  int get totalSales =>
      cash + card + otherPos + baemin + coupang + yogiyo + otherDelivery;

  Map<String, dynamic> toMap() {
    return {
      'cash': cash,
      'card': card,
      'otherPos': otherPos,
      'otherPosName': otherPosName,
      'baemin': baemin,
      'coupang': coupang,
      'yogiyo': yogiyo,
      'otherDelivery': otherDelivery,
      'otherDeliveryName': otherDeliveryName,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory SalesData.fromMap(Map<String, dynamic> map) {
    return SalesData(
      cash: map['cash'] ?? 0,
      card: map['card'] ?? 0,
      otherPos: map['otherPos'] ?? 0,
      otherPosName: map['otherPosName'] ?? '',
      baemin: map['baemin'] ?? 0,
      coupang: map['coupang'] ?? 0,
      yogiyo: map['yogiyo'] ?? 0,
      otherDelivery: map['otherDelivery'] ?? 0,
      otherDeliveryName: map['otherDeliveryName'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
    );
  }
}

class SalesDataProvider extends ChangeNotifier {
  SalesData? _latestSalesData;
  final List<SalesData> _salesHistory = [];

  SalesData? get latestSalesData => _latestSalesData;
  List<SalesData> get salesHistory => _salesHistory;

  void addSalesData(SalesData data) {
    _latestSalesData = data;
    _salesHistory.add(data);
    notifyListeners();
  }

  void clearSalesData() {
    _latestSalesData = null;
    notifyListeners();
  }
}
