import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../providers/store_provider.dart';
import '../providers/sales_data_provider.dart' as sales_provider;
import '../providers/expense_data_provider.dart' as expense_provider;
import 'sales_screen.dart';
import 'expense_screen.dart';
import 'comparison_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SalesScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExpenseScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ComparisonScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final salesDataProvider =
        Provider.of<sales_provider.SalesDataProvider>(context);
    final expenseDataProvider =
        Provider.of<expense_provider.ExpenseDataProvider>(context);

    final today = DateTime.now();
    final todaySales = salesDataProvider.getTotalSalesForDate(today);
    final todayExpenses = expenseDataProvider.getTotalExpensesForDate(today);
    final todayProfit = todaySales - todayExpenses;

    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 0);
    final monthSales =
        salesDataProvider.getTotalSalesForDateRange(monthStart, monthEnd);
    final monthExpenses =
        expenseDataProvider.getTotalExpensesForDateRange(monthStart, monthEnd);
    final monthProfit = monthSales - monthExpenses;
    final monthProfitRate =
        monthSales > 0 ? (monthProfit / monthSales * 100) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SONIK',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 매장명 선택
                    Row(
                      children: [
                        Text(
                          storeProvider.selectedStore?.name ?? '매장을 선택하세요',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '매장 선택',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ...storeProvider.stores
                                        .map((store) => ListTile(
                                              title: Text(store.name),
                                              subtitle: Text(store.address),
                                              onTap: () {
                                                storeProvider
                                                    .selectStore(store);
                                                Navigator.pop(context);
                                              },
                                            )),
                                    ListTile(
                                      leading: const Icon(Icons.add),
                                      title: const Text('새 매장 추가'),
                                      onTap: () {
                                        // TODO: 새 매장 추가 기능 구현
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // 알림과 설정 버튼
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            // TODO: 알림 기능 구현
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            // TODO: 설정 기능 구현
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 광고 배너
              Container(
                width: double.infinity,
                height: 60,
                color: Colors.grey[200],
                child: const Center(
                  child: Text('광고 영역'),
                ),
              ),
              const SizedBox(height: 16),
              // 매출 정보 카드
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: const Color(0xFFE8EAF6),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '오늘의 매출',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          Text(
                            '₩${NumberFormat('#,###').format(todaySales)}',
                            style: const TextStyle(
                              fontSize: 18,
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
                            '오늘의 매출목표',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          Text(
                            '₩${NumberFormat('#,###').format(todaySales * 1.2)}',
                            style: const TextStyle(
                              fontSize: 18,
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
                            '한달 손익률',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          Text(
                            '${monthProfitRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: monthProfitRate >= 0
                                  ? Colors.black
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 손익 정보 카드
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: const Color(0xFFE8EAF6),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '오늘의 손익',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          Text(
                            '₩${NumberFormat('#,###').format(todayProfit)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  todayProfit >= 0 ? Colors.black : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '한달 손익',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          Text(
                            '₩${NumberFormat('#,###').format(monthProfit)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  monthProfit >= 0 ? Colors.black : Colors.red,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '매출등록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: '지출등록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '비교통계',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SalesScreen()),
            );
          } else if (_selectedIndex == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExpenseScreen()),
            );
          }
        },
        backgroundColor: const Color(0xFF3F51B5),
        child: const Icon(Icons.add),
      ),
    );
  }
}
