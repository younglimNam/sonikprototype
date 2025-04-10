import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationCard(
            '매출 알림',
            '오늘의 매출이 목표치에 도달했습니다!',
            DateTime.now().subtract(const Duration(hours: 2)),
            Icons.attach_money,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            '지출 알림',
            '이번 달 고정 지출이 예산을 초과했습니다.',
            DateTime.now().subtract(const Duration(days: 1)),
            Icons.money_off,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            '시스템 알림',
            '새로운 기능이 추가되었습니다.',
            DateTime.now().subtract(const Duration(days: 3)),
            Icons.info,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    String title,
    String message,
    DateTime time,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${time.month}월 ${time.day}일 ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
