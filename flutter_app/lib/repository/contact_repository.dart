import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

class ContactRepository {
  static const String _key = 'contacts';

  Future<List<ContactModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    final contacts = decoded
        .whereType<Map>()
        .map((e) => ContactModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    contacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return contacts;
  }

  Future<void> add({required String name, required String address}) async {
    final contacts = await getAll();
    final nextId = contacts.isEmpty
        ? 1
        : contacts.map((e) => e.id).reduce(max) + 1;

    final updated = [
      ...contacts,
      ContactModel(id: nextId, name: name, address: address),
    ];

    await _save(updated);
  }

  Future<void> delete(int id) async {
    final contacts = await getAll();
    final updated = contacts.where((c) => c.id != id).toList();
    await _save(updated);
  }

  Future<void> _save(List<ContactModel> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(contacts.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
