import 'package:flutter/material.dart';
import 'package:safemate/screens/add_contact_screen.dart';
import 'package:safemate/utils(helper)/contact_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact_model.dart';

class ViewContactsScreen extends StatefulWidget {
  const ViewContactsScreen({super.key});

  @override
  State<ViewContactsScreen> createState() => _ViewContactsScreenState();
}

class _ViewContactsScreenState extends State<ViewContactsScreen> {
  List<EmergencyContact> contacts = [];

  Future<void> _loadContacts() async {
    contacts = await ContactHelper.getContacts();
    setState(() {});
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _delete(int index) async {
    await ContactHelper.deleteContact(index);
    _loadContacts();
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29), // Matching dark background
      appBar: AppBar(
        title: const Text(
          "My Emergency Contacts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF302B63),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: contacts.isEmpty
          ? const Center(
              child: Text(
                "No contacts added",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final c = contacts[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(
                      c.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      c.number,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.greenAccent),
                          onPressed: () => _call(c.number),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _delete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE94057),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddContactScreen()),
          ).then((_) => _loadContacts());
        },
      ),
    );
  }
}
