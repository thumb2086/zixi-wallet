import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      );

      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      debugPrint('Notification initialize skipped: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
      default:
        return;
    }

    await initialize();

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showBalanceNotification({required double amount, required double total}) async {
    if (kIsWeb) return;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
      default:
        return;
    }

    await initialize();

    const android = AndroidNotificationDetails(
      'balance_alerts',
      'Balance Alerts',
      channelDescription: 'Notify when account balance increases',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(
      android: android,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const title = 'Token Deposit';
    final body =
        'Received ${amount.toStringAsFixed(2)} tokens. Current balance: ${total.toStringAsFixed(2)}';

    await _plugin.show(id, title, body, details);
  }
}
