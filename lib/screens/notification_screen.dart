import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('알림 화면'),
      ),
    );
  }
}
