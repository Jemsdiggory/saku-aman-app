import '../database/db_helper.dart';

class InsightService {

  static DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        final year  = parts[0].padLeft(4, '0');
        final month = parts[1].padLeft(2, '0');
        final day   = parts[2].substring(0, 2).padLeft(2, '0');
        return DateTime.parse('$year-$month-$day');
      }
      return DateTime.now();
    }
  }

  static Future<List<Map<String, dynamic>>> generateInsights() async {
    final all = await DbHelper.instance.getAllExpenses();
    final now = DateTime.now();
    final insights = <Map<String, dynamic>>[];

    if (all.isEmpty) return insights;

    // Hari ini
    final today = all.where((e) {
      final d = _parseDate(e.date);
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    // Minggu ini
    final thisWeek = all.where((e) {
      final d = _parseDate(e.date);
      return d.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    // Minggu lalu
    final lastWeek = all.where((e) {
      final d = _parseDate(e.date);
      return d.isAfter(now.subtract(const Duration(days: 14))) &&
             d.isBefore(now.subtract(const Duration(days: 7)));
    }).toList();

    // Bulan ini
    final thisMonth = all.where((e) {
      final d = _parseDate(e.date);
      return d.month == now.month && d.year == now.year;
    }).toList();

    // Bulan lalu
    final lastMonthDate = DateTime(now.year, now.month - 1);
    final lastMonth = all.where((e) {
      final d = _parseDate(e.date);
      return d.month == lastMonthDate.month && d.year == lastMonthDate.year;
    }).toList();

    // ================================
    // INSIGHT 1: Transaksi terlalu sering hari ini
    // ================================
    if (today.length >= 5) {
      insights.add({
        'icon': 'warning',
        'title': 'Transaksi Sering Banget!',
        'message': 'Kamu sudah ${today.length}x transaksi hari ini. Hati-hati pengeluaran kecil yang menumpuk!',
        'type': 'warning',
      });
    }

    // ================================
    // INSIGHT 2: Pengeluaran minggu ini vs minggu lalu
    // ================================
    final totalThisWeek = thisWeek.fold(0, (s, e) => s + e.amount);
    final totalLastWeek = lastWeek.fold(0, (s, e) => s + e.amount);

    if (totalLastWeek > 0) {
      final diff = ((totalThisWeek - totalLastWeek) / totalLastWeek * 100).round();
      if (diff > 20) {
        insights.add({
          'icon': 'trending_up',
          'title': 'Pengeluaran Naik!',
          'message': 'Minggu ini kamu boros $diff% lebih banyak dari minggu lalu. Yuk dikurangi!',
          'type': 'warning',
        });
      } else if (diff < -20) {
        insights.add({
          'icon': 'trending_down',
          'title': 'Pengeluaran Turun!',
          'message': 'Hebat! Minggu ini kamu hemat ${diff.abs()}% dibanding minggu lalu. Pertahankan!',
          'type': 'success',
        });
      }
    }

    // ================================
    // INSIGHT 3: Kategori terboros minggu ini
    // ================================
    if (thisWeek.isNotEmpty) {
      final Map<String, int> catTotal = {};
      for (final e in thisWeek) {
        catTotal[e.category] = (catTotal[e.category] ?? 0) + e.amount;
      }
      final topCat = catTotal.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (topCat.isNotEmpty) {
        final top = topCat.first;
        final pct = (top.value / totalThisWeek * 100).round();
        if (pct >= 50) {
          insights.add({
            'icon': 'category',
            'title': 'Kategori Terboros',
            'message': '$pct% pengeluaran minggu ini habis untuk ${top.key}. Mau dikurangi?',
            'type': 'info',
          });
        }
      }
    }

    // ================================
    // INSIGHT 4: Pengeluaran bulan ini vs bulan lalu
    // ================================
    final totalThisMonth = thisMonth.fold(0, (s, e) => s + e.amount);
    final totalLastMonth = lastMonth.fold(0, (s, e) => s + e.amount);

    if (totalLastMonth > 0) {
      final diff = ((totalThisMonth - totalLastMonth) / totalLastMonth * 100).round();
      if (diff > 30) {
        insights.add({
          'icon': 'calendar_month',
          'title': 'Pengeluaran Bulan Ini Melonjak!',
          'message': 'Bulan ini kamu sudah lebih boros $diff% dibanding bulan lalu.',
          'type': 'warning',
        });
      } else if (diff < -30) {
        insights.add({
          'icon': 'savings',
          'title': 'Bulan Ini Lebih Hemat!',
          'message': 'Pengeluaran bulan ini turun ${diff.abs()}% dari bulan lalu. Keren!',
          'type': 'success',
        });
      }
    }

    // ================================
      // INSIGHT GAME: Kebanyakan ngegame bro!
      // ================================
      if (thisWeek.isNotEmpty) {
        final gameTotal = thisWeek
            .where((e) => e.category == 'Game')
            .fold(0, (s, e) => s + e.amount);
        final gameCount = thisWeek.where((e) => e.category == 'Game').length;
        final gamePct = totalThisWeek > 0
            ? (gameTotal / totalThisWeek * 100).round()
            : 0;

        if (gamePct >= 30) {
          insights.add({
            'icon': 'game',
            'title': 'Bro, Sadar Ga?! 💸',
            'message': '$gamePct% duit kamu minggu ini abis buat game. '
                'Udah $gameCount transaksi game! '
                'Mending ditabung, masa kalah sama skin doang?',
            'type': 'warning',
          });
        } else if (gameCount >= 3) {
          insights.add({
            'icon': 'game',
            'title': 'Game Addict Detected 🎮',
            'message': 'Udah $gameCount kali beli sesuatu buat game minggu ini. '
                'Ingat, rank bisa naik tapi dompet bisa kosong!',
            'type': 'warning',
          });
        }
      }

    // ================================
    // INSIGHT 5: Hari paling boros minggu ini
    // ================================
    if (thisWeek.isNotEmpty) {
      final Map<String, int> dayTotal = {};
      for (final e in thisWeek) {
        final d = _parseDate(e.date);
        final dayKey = '${d.year}-${d.month}-${d.day}';
        dayTotal[dayKey] = (dayTotal[dayKey] ?? 0) + e.amount;
      }
      final sortedDays = dayTotal.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedDays.isNotEmpty) {
        final topDay = _parseDate(sortedDays.first.key);
        final days = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
        final dayName = days[topDay.weekday - 1];
        insights.add({
          'icon': 'today',
          'title': 'Hari Paling Boros',
          'message': 'Hari $dayName adalah hari paling boros kamu minggu ini.',
          'type': 'info',
        });
      }
    }

    // ================================
    // INSIGHT 6: Kalau tidak ada masalah
    // ================================
    if (insights.isEmpty) {
      insights.add({
        'icon': 'check_circle',
        'title': 'Keuangan Aman!',
        'message': 'Pengeluaran kamu terkontrol dengan baik. Terus pertahankan!',
        'type': 'success',
      });
    }

    return insights;
  }
}