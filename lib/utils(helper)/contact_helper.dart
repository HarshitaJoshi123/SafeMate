import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';

class ContactHelper {
  static const _key = 'emergency_contacts';

  static Future<List<EmergencyContact>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map((str) => EmergencyContact.fromJson(jsonDecode(str)))
        .toList();
  }

  static Future<void> saveContact(EmergencyContact contact) async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = await getContacts();
    contacts.add(contact);
    final stringList =
        contacts.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_key, stringList);
  }

  static Future<void> deleteContact(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = await getContacts();
    contacts.removeAt(index);
    final stringList =
        contacts.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_key, stringList);
  }
}
