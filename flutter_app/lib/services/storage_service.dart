import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/translation.dart';
import '../models/token.dart';

class AppStorage {
  AppStorage._();

  static const String _languageKey = 'app_language';
  static const String _lastBalanceKeyPrefix = 'last_known_balance_';
  static const String _deviceIdKey = 'device_id';
  static const String _activeSessionIdKey = 'active_session_id';
  static const String _autoUpdateCheckEnabledKey = 'auto_update_check_enabled';

  static Future<AppLanguage> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_languageKey) ?? 'system';
    return AppLanguageTag.fromTag(raw);
  }

  static Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.tag);
  }

  static Future<Map<String, double>> getLastKnownBalances() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final token in AppToken.supported)
        token.id: double.tryParse(
              prefs.getString('$_lastBalanceKeyPrefix${token.id}') ?? '0.0',
            ) ??
            0.0,
    };
  }

  static Future<void> setLastKnownBalance(String tokenId, String balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_lastBalanceKeyPrefix$tokenId', balance);
  }

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final generated = 'dlinker_${base64UrlEncode(bytes).replaceAll('=', '')}';

    await prefs.setString(_deviceIdKey, generated);
    return generated;
  }

  static Future<String> getActiveSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeSessionIdKey) ?? '';
  }

  static Future<void> setActiveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeSessionIdKey, sessionId.trim());
  }

  static Future<void> clearActiveSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeSessionIdKey);
  }

  static Future<bool> getAutoUpdateCheckEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoUpdateCheckEnabledKey) ?? true;
  }

  static Future<void> setAutoUpdateCheckEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoUpdateCheckEnabledKey, enabled);
  }
}
