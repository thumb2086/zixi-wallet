import 'package:flutter/material.dart';

import '../../l10n/translation.dart';

class AddressInputResult {
  const AddressInputResult({
    required this.action,
    required this.value,
  });

  final AddressInputAction action;
  final String value;
}

enum AddressInputAction { confirm, scan, contacts }

Future<AddressInputResult?> showAddressInputDialog(
  BuildContext context, {
  required bool isMigration,
}) {
  final controller = TextEditingController();
  return showDialog<AddressInputResult>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(T.of(context, isMigration ? 'migration' : 'manual_address_input')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: T.of(context, 'address_placeholder'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(
                      const AddressInputResult(action: AddressInputAction.contacts, value: ''),
                    );
                  },
                  icon: const Icon(Icons.contacts),
                  label: Text(T.of(context, 'contacts')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(
                      const AddressInputResult(action: AddressInputAction.scan, value: ''),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(T.of(context, 'scan')),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(T.of(context, 'cancel')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              AddressInputResult(action: AddressInputAction.confirm, value: controller.text),
            );
          },
          child: Text(T.of(context, 'confirm')),
        ),
      ],
    ),
  );
}

Future<String?> showTransferDialog(
  BuildContext context, {
  required String toAddress,
  required bool isMigration,
  required String presetAmount,
  String tokenDisplayName = '',
}) {
  final controller = TextEditingController(text: presetAmount);

  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        isMigration
            ? T.of(context, 'migration_title')
            : T.of(context, 'send_symbol', [tokenDisplayName]),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(T.of(context, 'to_address', [toAddress]), style: const TextStyle(fontSize: 12)),
          if (isMigration) ...[
            const SizedBox(height: 8),
            Text(T.of(context, 'migration_desc'), style: const TextStyle(fontSize: 12)),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            readOnly: isMigration,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: T.of(context, 'amount'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(T.of(context, 'cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(T.of(context, isMigration ? 'migration_confirm' : 'confirm_send')),
        ),
      ],
    ),
  );
}
