import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/translation.dart';
import '../models/contact.dart';
import '../repository/contact_repository.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({
    super.key,
    required this.selectionMode,
    required this.repository,
  });

  final bool selectionMode;
  final ContactRepository repository;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<ContactModel> _contacts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final contacts = await widget.repository.getAll();
    if (!mounted) return;
    setState(() {
      _contacts = contacts;
      _loading = false;
    });
  }

  Future<void> _addContact() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    final save = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(T.of(context, 'add_contact')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: T.of(context, 'contact_name')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: T.of(context, 'wallet_address')),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(T.of(context, 'cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(T.of(context, 'confirm')),
              ),
            ],
          ),
        ) ??
        false;

    if (!save) return;

    final name = nameController.text.trim();
    final address = addressController.text.trim();
    if (name.isEmpty || address.isEmpty) return;

    await widget.repository.add(name: name, address: address);
    await _load();
  }

  Future<void> _deleteContact(ContactModel contact) async {
    await widget.repository.delete(contact.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectionMode ? T.of(context, 'select_contact') : T.of(context, 'contacts'),
        ),
        actions: [
          IconButton(
            onPressed: _addContact,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? Center(
                  child: Text(
                    T.of(context, 'no_contacts'),
                    style: TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                )
              : ListView.separated(
                  itemCount: _contacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return ListTile(
                      title: Text(contact.name),
                      subtitle: Text(
                        contact.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: widget.selectionMode
                          ? null
                          : IconButton(
                              onPressed: () => _deleteContact(contact),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                      onTap: () async {
                        if (widget.selectionMode) {
                          Navigator.of(context).pop(contact.address);
                          return;
                        }

                        await Clipboard.setData(ClipboardData(text: contact.address));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(T.of(context, 'copy_success'))),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
