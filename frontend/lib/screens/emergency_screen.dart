import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Load saved contacts from storage
  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phone1Controller.text = prefs.getString('sos_phone_1') ?? '';
      _phone2Controller.text = prefs.getString('sos_phone_2') ?? '';
    });
  }

  // Save contacts to storage
  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sos_phone_1', _phone1Controller.text.trim());
    await prefs.setString('sos_phone_2', _phone2Controller.text.trim());
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency Contacts Saved Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Add trusted contacts who will receive your GPS location during an emergency.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phone1Controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Primary Contact (e.g., +91XXXXXXXXXX)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phone2Controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Secondary Contact (e.g., +91XXXXXXXXXX)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _saveContacts,
              child: const Text('Save Contacts'),
            ),
          ],
        ),
      ),
    );
  }
}