import 'package:flutter/material.dart';
import 'package:saku_aman_app/main.dart';
import '../database/db_helper.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  int _totalToday = 0;
  int _totalWeek = 0;
  int _totalMonth = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await DbHelper.instance.getAllExpenses();
    final today = await DbHelper.instance.getTodayExpenses();
    final now = DateTime.now();

    final weekExpenses = all.where((e) {
      final date = DateTime.parse(e.date);
      return date.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    final monthExpenses = all.where((e) {
      final date = DateTime.parse(e.date);
      return date.month == now.month && date.year == now.year;
    }).toList();

    setState(() {
      _expenses = all;
      _totalToday = today.fold(0, (sum, e) => sum + e.amount);
      _totalWeek = weekExpenses.fold(0, (sum, e) => sum + e.amount);
      _totalMonth = monthExpenses.fold(0, (sum, e) => sum + e.amount);
    });
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Makan':      return Icons.restaurant;
      case 'Transport':  return Icons.directions_car;
      case 'Belanja':    return Icons.shopping_bag;
      case 'Hiburan':    return Icons.movie;
      case 'Game':       return Icons.videogame_asset;
      case 'Tagihan':    return Icons.receipt;
      default:           return Icons.more_horiz;
    }
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Agu','Sep','Okt','Nov','Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _deleteExpense(int id) async {
    await DbHelper.instance.deleteExpense(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor  = isDark ? const Color(0xFF1E1E2E) : const Color(0xFF2D3748);
    final cardColor    = isDark ? const Color(0xFF1E1E2E) : const Color(0xFF3D4A5C);
    final bgColor      = isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    final surfaceColor = isDark ? const Color(0xFF2A2A3E) : Colors.white;
    final fabColor     = isDark ? const Color(0xFF6C63FF) : const Color(0xFF2D3748);
    final labelColor   = isDark ? Colors.white : const Color(0xFF2D3748);
    final subColor     = isDark ? Colors.white60 : const Color(0xFF718096);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('Saku Aman', style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
          ],
        ),
        centerTitle: true,
        actions: [
          const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6_outlined, color: Colors.white, size: 22),
            onSelected: (mode) => MyApp.of(context)?.toggleTheme(mode),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Row(children: [
                  Icon(Icons.phone_android, size: 18), SizedBox(width: 8), Text('Ikut Device'),
                ]),
              ),
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Row(children: [
                  Icon(Icons.light_mode, size: 18), SizedBox(width: 8), Text('Light Mode'),
                ]),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(children: [
                  Icon(Icons.dark_mode, size: 18), SizedBox(width: 8), Text('Dark Mode'),
                ]),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // CARD TOTAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Text('Total Pengeluaran Hari Ini',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                    _formatRupiah(_totalToday),
                    style: const TextStyle(
                      color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    _summaryChip(Icons.date_range, 'Minggu ini', _formatRupiah(_totalWeek)),
                    const SizedBox(width: 12),
                    _summaryChip(Icons.calendar_month, 'Bulan ini', _formatRupiah(_totalMonth)),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // LABEL
            Row(children: [
              Icon(Icons.receipt_long, size: 18, color: labelColor),
              const SizedBox(width: 6),
              Text('Transaksi Terakhir', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: labelColor,
              )),
            ]),

            const SizedBox(height: 12),

            // LIST atau EMPTY STATE
            Expanded(
              child: _expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: surfaceColor, shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.inbox_outlined, size: 48, color: subColor),
                          ),
                          const SizedBox(height: 16),
                          Text('Belum ada transaksi',
                              style: TextStyle(color: subColor, fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('Tap + untuk tambah pengeluaran',
                              style: TextStyle(color: subColor, fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _expenses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final e = _expenses[index];
                        return Dismissible(
                          key: Key(e.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white, size: 24),
                          ),
                          onDismissed: (_) => _deleteExpense(e.id!),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2D3748)
                                        : const Color(0xFFEDF2F7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_categoryIcon(e.category),
                                      size: 20, color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF2D3748)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.category,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: labelColor)),
                                      if (e.note.isNotEmpty)
                                        Text(e.note,
                                            style: TextStyle(
                                                color: subColor, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      Text(_formatDate(e.date),
                                          style: TextStyle(
                                              color: subColor, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatRupiah(e.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // COPYRIGHT ← ditambah di sini
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Center(
                child: Text(
                  '© 2025 Saku Aman by Jems',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: appBarColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (result == true) _loadData();
        },
        backgroundColor: fabColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: Colors.white60, size: 12),
      const SizedBox(width: 4),
      Text('$label: $value',
          style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ]);
  }
}