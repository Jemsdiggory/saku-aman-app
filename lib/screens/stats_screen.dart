import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/db_helper.dart';
import '../models/expense.dart';
import '../services/insight_service.dart';
import '../services/notification_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Map<String, dynamic>> _insights = [];
  List<Expense> _expenses = [];
  String _selectedFilter = 'Minggu ini';

  final List<String> _filters = ['Hari ini', 'Minggu ini', 'Bulan ini'];

  final Map<String, Color> _categoryColors = {
    'Makan':      Color(0xFF4A90D9),
    'Transport':  Color(0xFF7ED321),
    'Belanja':    Color(0xFFF5A623),
    'Hiburan':    Color(0xFFBD10E0),
    'Game':  Color(0xFF50E3C2),
    'Tagihan': Color(0xFFFF6B6B),
    'Lainnya':    Color(0xFF9B9B9B),
  };

  final Map<String, IconData> _categoryIcons = {
    'Makan':      Icons.restaurant,
    'Transport':  Icons.directions_car,
    'Belanja':    Icons.shopping_bag,
    'Hiburan':    Icons.movie,
    'Game':        Icons.videogame_asset,
    'Tagihan':     Icons.receipt,
    'Lainnya':    Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
  final insights = await InsightService.generateInsights();
  setState(() => _insights = insights);
  await NotificationService.notifyInsights(insights); // ← tambah ini
}


  Future<void> _loadData() async {
    final all = await DbHelper.instance.getAllExpenses();
    final now = DateTime.now();

    List<Expense> filtered;

    if (_selectedFilter == 'Hari ini') {
      filtered = all.where((e) {
        final date = DateTime.parse(e.date);
        return date.year == now.year &&
               date.month == now.month &&
               date.day == now.day;
      }).toList();
    } else if (_selectedFilter == 'Minggu ini') {
      final weekAgo = now.subtract(const Duration(days: 7));
      filtered = all.where((e) {
        final date = DateTime.parse(e.date);
        return date.isAfter(weekAgo);
      }).toList();
    } else {
      filtered = all.where((e) {
        final date = DateTime.parse(e.date);
        return date.month == now.month && date.year == now.year;
      }).toList();
    }

    setState(() => _expenses = filtered);
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

  Map<String, int> _groupByCategory() {
    final Map<String, int> result = {};
    for (final e in _expenses) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFF2D3748);
    final bgColor     = isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    final cardColor   = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final labelColor  = isDark ? Colors.white : const Color(0xFF2D3748);
    final subColor    = isDark ? Colors.white60 : const Color(0xFF718096);

    final grouped    = _groupByCategory();
    final total      = _expenses.fold(0, (sum, e) => sum + e.amount);
    final categories = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: const Text(
          'Statistik',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // FILTER CHIP
            Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      _loadData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2D3748)
                            : cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : subColor,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // CARD TOTAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFF3D4A5C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Icon(Icons.bar_chart, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text('Total Pengeluaran',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                  const SizedBox(height: 8),
                  Text(_formatRupiah(total),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${_expenses.length} transaksi',
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PIE CHART SECTION
            if (grouped.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.pie_chart_outline, size: 48, color: subColor),
                    const SizedBox(height: 12),
                    Text('Belum ada data',
                        style: TextStyle(color: subColor, fontSize: 14)),
                  ],
                ),
              )
            else ...[

              Row(children: [
                Icon(Icons.donut_large, size: 18, color: labelColor),
                const SizedBox(width: 6),
                Text('Per Kategori', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: labelColor)),
              ]),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          sections: categories.asMap().entries.map((entry) {
                            final cat = entry.value;
                            final pct = total > 0
                                ? (cat.value / total * 100).toStringAsFixed(1)
                                : '0';
                            return PieChartSectionData(
                              color: _categoryColors[cat.key] ?? const Color(0xFF9B9B9B),
                              value: cat.value.toDouble(),
                              title: '$pct%',
                              radius: 58,
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                color: _categoryColors[cat.key],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(cat.key,
                                style: TextStyle(color: subColor, fontSize: 12)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(children: [
                Icon(Icons.list_alt, size: 18, color: labelColor),
                const SizedBox(width: 6),
                Text('Breakdown', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: labelColor)),
              ]),
              const SizedBox(height: 12),

              ...categories.map((cat) {
                final pct = total > 0 ? cat.value / total : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (_categoryColors[cat.key] ?? const Color(0xFF9B9B9B))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _categoryIcons[cat.key] ?? Icons.more_horiz,
                          size: 18,
                          color: _categoryColors[cat.key],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat.key, style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: labelColor, fontSize: 13)),
                                Text(_formatRupiah(cat.value), style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: labelColor, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: isDark
                                    ? Colors.white12
                                    : const Color(0xFFEDF2F7),
                                color: _categoryColors[cat.key],
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // INSIGHT SECTION
              Row(children: [
                Icon(Icons.lightbulb_outline, size: 18, color: labelColor),
                const SizedBox(width: 6),
                Text('Insight', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: labelColor)),
              ]),
              const SizedBox(height: 12),

              ..._insights.map((insight) {
                final type = insight['type'] as String;
                final bgInsight = type == 'warning'
                    ? const Color(0xFFFFF3CD)
                    : type == 'success'
                        ? const Color(0xFFD4EDDA)
                        : const Color(0xFFD1ECF1);
                final bgDark = type == 'warning'
                    ? const Color(0xFF3D3000)
                    : type == 'success'
                        ? const Color(0xFF003D1A)
                        : const Color(0xFF003D4A);
                final iconColor = type == 'warning'
                    ? const Color(0xFFF5A623)
                    : type == 'success'
                        ? const Color(0xFF28A745)
                        : const Color(0xFF17A2B8);

                IconData iconData;
                switch (insight['icon']) {
                  case 'trending_up':    iconData = Icons.trending_up; break;
                  case 'trending_down':  iconData = Icons.trending_down; break;
                  case 'warning':        iconData = Icons.warning_amber_outlined; break;
                  case 'category':       iconData = Icons.category_outlined; break;
                  case 'calendar_month': iconData = Icons.calendar_month_outlined; break;
                  case 'savings':        iconData = Icons.savings_outlined; break;
                  case 'today':          iconData = Icons.today_outlined; break;
                  case 'game': iconData = Icons.sports_esports; break;
                  default:               iconData = Icons.check_circle_outline;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? bgDark : bgInsight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(iconData, color: iconColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(insight['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                                  fontSize: 13,
                                )),
                            const SizedBox(height: 4),
                            Text(insight['message'],
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}