import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hubungi Kami'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 48,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kue Kering Made by Mommy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFFFE8C00)),
            title: const Text('082216849581'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Color(0xFFFE8C00)),
            title: const Text('kukerbymommy@gmail.com'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}