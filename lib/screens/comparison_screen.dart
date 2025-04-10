import 'package:flutter/material.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비교 분석'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('비교 분석 화면'),
      ),
    );
  }
}
