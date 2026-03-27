import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart'; // ← tambah ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← tambah ini
  await NotificationService.init();           // ← tambah ini
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // ignore: library_private_types_in_public_api
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saku Aman',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const ScrollBehaviorNoGlow(), // ← ditambah di sini

      // LIGHT THEME
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 172, 12, 12)),
        useMaterial3: true,
        brightness: Brightness.light,
      ),

      // DARK THEME
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 172, 12, 12),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),

      themeMode: _themeMode,
      home: const HomeScreen(),
    );
  }
}

// ← class baru ditambah di sini
class ScrollBehaviorNoGlow extends ScrollBehavior {
  const ScrollBehaviorNoGlow();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}