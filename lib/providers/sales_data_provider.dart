import 'package:flutter/foundation.dart';
import '../models/sales_data.dart';

class SalesDataProvider with ChangeNotifier {
  final List<SalesData> _salesData = [];

  SalesData? get latestSalesData =>
      _salesData.isNotEmpty ? _salesData.last : null;

  void addSalesData(SalesData data) {
    _salesData.add(data);
    notifyListeners();
  }

  int getTotalSalesForDate(DateTime date) {
    final salesData = _salesData.where((data) =>
        data.date.year == date.year &&
        data.date.month == date.month &&
        data.date.day == date.day);

    return salesData.fold(0, (sum, data) => sum + data.totalSales);
  }

  int getTotalSalesForDateRange(DateTime start, DateTime end) {
    final salesData = _salesData.where((data) =>
        data.date.isAfter(start.subtract(const Duration(days: 1))) &&
        data.date.isBefore(end.add(const Duration(days: 1))));

    return salesData.fold(0, (sum, data) => sum + data.totalSales);
  }
}
