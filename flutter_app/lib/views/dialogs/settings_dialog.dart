import 'package:flutter/material.dart';

import '../../l10n/translation.dart';
import '../../services/storage_service.dart';

Future<void> showSettingsDialog(
  BuildContext context, {
  required bool initialAutoUpdateEnabled,
  required AppLanguage currentLanguage,
  required Future<void> Function(AppLanguage language) onLanguageChanged,
  required ValueChanged<bool> onAutoUpdateChanged,
}) {
  bool autoUpdateEnabled = initialAutoUpdateEnabled;

  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(T.of(context, 'settings')),
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(T.of(context, 'auto_update_check')),
              value: autoUpdateEnabled,
              onChanged: (enabled) async {
                setDialogState(() {
                  autoUpdateEnabled = enabled;
                });
                await AppStorage.setAutoUpdateCheckEnabled(enabled);
                onAutoUpdateChanged(enabled);
              },
            ),
            _languageTile(context, dialogContext, AppLanguage.system, T.of(context, 'lang_auto'),
                currentLanguage, onLanguageChanged),
            _languageTile(context, dialogContext, AppLanguage.zhTw, T.of(context, 'lang_zh_tw'),
                currentLanguage, onLanguageChanged),
            _languageTile(context, dialogContext, AppLanguage.zhCn, T.of(context, 'lang_zh_cn'),
                currentLanguage, onLanguageChanged),
            _languageTile(context, dialogContext, AppLanguage.en, T.of(context, 'lang_en'),
                currentLanguage, onLanguageChanged),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(T.of(context, 'close')),
        ),
      ],
    ),
  );
}

Widget _languageTile(
  BuildContext outerContext,
  BuildContext dialogContext,
  AppLanguage language,
  String label,
  AppLanguage currentLanguage,
  Future<void> Function(AppLanguage language) onLanguageChanged,
) {
  final isSelected = currentLanguage == language;
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    leading: Icon(
      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
    ),
    onTap: () async {
      if (isSelected) {
        Navigator.of(dialogContext).pop();
        return;
      }
      await onLanguageChanged(language);
      if (outerContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    },
  );
}
