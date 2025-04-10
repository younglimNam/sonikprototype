import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

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
