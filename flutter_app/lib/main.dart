import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/translation.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'views/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeviceLinkerApp());
  unawaited(NotificationService.instance.initialize());
}

class DeviceLinkerApp extends StatefulWidget {
  const DeviceLinkerApp({super.key});

  @override
  State<DeviceLinkerApp> createState() => _DeviceLinkerAppState();
}

class _DeviceLinkerAppState extends State<DeviceLinkerApp> {
  AppLanguage _language = AppLanguage.system;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final language = await AppStorage.getLanguage();
    if (!mounted) return;
    setState(() {
      _language = language;
      _ready = true;
    });
  }

  Future<void> _onLanguageChanged(AppLanguage language) async {
    await AppStorage.setLanguage(language);
    if (!mounted) return;
    setState(() {
      _language = language;
    });
  }

  Locale? get _locale {
    switch (_language) {
      case AppLanguage.system:
        return null;
      case AppLanguage.zhTw:
        return const Locale('zh', 'TW');
      case AppLanguage.zhCn:
        return const Locale('zh', 'CN');
      case AppLanguage.en:
        return const Locale('en');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'D-Linker',
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('zh', 'TW'),
        Locale('zh', 'CN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: DashboardScreen(
        language: _language,
        onLanguageChanged: _onLanguageChanged,
      ),
    );
  }
}
