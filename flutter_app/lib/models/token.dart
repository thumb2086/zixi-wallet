import 'package:flutter/material.dart';

class AppToken {
  const AppToken({
    required this.id,
    required this.address,
    required this.symbol,
    required this.nameEn,
    required this.nameZhTw,
    required this.nameZhCn,
  });

  final String id;
  final String address;
  final String symbol;
  final String nameEn;
  final String nameZhTw;
  final String nameZhCn;

  static const List<AppToken> supported = [
    AppToken(
      id: 'zhixi',
      address: '0xe3d9af5f15857cb01e0614fa281fcc3256f62050',
      symbol: 'ZHIXI',
      nameEn: 'Zhixi Coin',
      nameZhTw: '子熙幣',
      nameZhCn: '子熙币',
    ),
    AppToken(
      id: 'yjc',
      address: '0x82D6aDB17d58820324D86B378775350D03a071AE',
      symbol: 'YJC',
      nameEn: 'YouJian Coin',
      nameZhTw: '佑戩幣',
      nameZhCn: '佑戩币',
    ),
  ];

  String displayName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh' && locale.countryCode?.toUpperCase() == 'TW') {
      return nameZhTw;
    }
    if (locale.languageCode == 'zh') {
      return nameZhCn;
    }
    return nameEn;
  }
}
