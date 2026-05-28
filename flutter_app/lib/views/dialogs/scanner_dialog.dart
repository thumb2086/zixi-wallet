import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/translation.dart';

class ScannerDialog extends StatefulWidget {
  const ScannerDialog({
    super.key,
    required this.scannerSupported,
  });

  final bool scannerSupported;

  @override
  State<ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<ScannerDialog> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emit(String value) {
    if (_handled || value.trim().isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(value.trim());
  }

  Future<void> _openManualInputDialog() async {
    final controller = TextEditingController();
    final manual = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(T.of(context, 'manual_code_entry')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: T.of(context, 'manual_code_hint'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(T.of(context, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(T.of(context, 'confirm')),
          ),
        ],
      ),
    );

    if (!mounted || manual == null || manual.isEmpty) return;
    _emit(manual);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 420,
        height: 470,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 6, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      T.of(context, 'scan'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.scannerSupported
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: MobileScanner(
                          controller: _controller,
                          onDetect: (capture) {
                            if (capture.barcodes.isEmpty) return;
                            final raw = capture.barcodes.first.rawValue;
                            if (raw == null) return;
                            _emit(raw);
                          },
                        ),
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          T.of(context, 'camera_permission_required'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _openManualInputDialog,
                      child: Text(T.of(context, 'manual_code_entry')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(T.of(context, 'close')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
