import 'package:flutter/material.dart';

import '../../l10n/translation.dart';

Future<String?> showPinSetupDialog(BuildContext context) async {
  final pinController = TextEditingController();
  final confirmController = TextEditingController();
  String? errorText;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(T.of(context, 'pin_setup_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(T.of(context, 'pin_setup_desc')),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: T.of(context, 'pin_enter'),
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: T.of(context, 'pin_confirm'),
                counterText: '',
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              final pin = pinController.text.trim();
              final confirm = confirmController.text.trim();

              if (pin.length != 6 || int.tryParse(pin) == null) {
                setDialogState(() => errorText = T.of(dialogContext, 'pin_invalid'));
                return;
              }

              if (pin != confirm) {
                setDialogState(() => errorText = T.of(dialogContext, 'pin_mismatch'));
                return;
              }

              Navigator.of(dialogContext).pop(pin);
            },
            child: Text(T.of(context, 'confirm')),
          ),
        ],
      ),
    ),
  );
}

Future<String?> showPinUnlockDialog(BuildContext context) async {
  final pinController = TextEditingController();
  String? errorText;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(T.of(context, 'pin_unlock_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(T.of(context, 'pin_unlock_desc')),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: T.of(context, 'pin_enter'),
                counterText: '',
              ),
              autofocus: true,
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(T.of(context, 'cancel')),
          ),
          FilledButton(
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length != 6 || int.tryParse(pin) == null) {
                setDialogState(() => errorText = T.of(dialogContext, 'pin_invalid'));
                return;
              }
              Navigator.of(dialogContext).pop(pin);
            },
            child: Text(T.of(context, 'confirm')),
          ),
        ],
      ),
    ),
  );
}
