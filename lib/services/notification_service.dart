import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();

    const InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios); // fix ios

    await _notifications.initialize(settings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> showInsightNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'insight_channel',
      'Insight Keuangan',
      channelDescription: 'Notifikasi insight pengeluaran dari Saku Aman',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(); // ← tambah ini untuk iOS

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails, // ← tambah ini untuk iOS
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  static Future<void> notifyInsights(
      List<Map<String, dynamic>> insights) async {
    final List<Map<String, dynamic>> warnings =
        insights.where((i) => i['type'] == 'warning').toList();

    for (final insight in warnings) {
      await showInsightNotification(
        title: insight['title'],
        body: insight['message'],
      );
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}