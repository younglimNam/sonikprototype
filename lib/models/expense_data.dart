import 'package:flutter/foundation.dart';

class ExpenseData {
  final DateTime date;
  final String category;
  final String subCategory;
  final int amount;

  ExpenseData({
    required this.date,
    required this.category,
    required this.subCategory,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'category': category,
      'subCategory': subCategory,
      'amount': amount,
    };
  }

  factory ExpenseData.fromMap(Map<String, dynamic> map) {
    return ExpenseData(
      date: DateTime.parse(map['date']),
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      amount: map['amount'] ?? 0,
    );
  }
}
