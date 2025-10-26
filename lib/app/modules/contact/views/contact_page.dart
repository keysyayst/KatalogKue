import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

class ContactPage extends GetView<ContactController> {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hubungi Kami & Tes API'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (Info Kontak Anda tetap di sini) ...
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kue Kering Made by Mommy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Divider(),

            // ===========================================
            // --- BAGIAN 1: EKSPERIMEN PERFORMA ---
            // ===========================================
            const Text(
              'Eksperimen Performa (Tugas 1)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // --- Tes HTTP ---
            ElevatedButton(
              onPressed: () =>
                  controller.isLoading.value ? null : controller.runHttpTest(),
              child: const Text('Jalankan Tes HTTP (Sukses)'),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.httpResult.value,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // --- Tes Dio ---
            ElevatedButton(
              onPressed: () =>
                  controller.isLoading.value ? null : controller.runDioTest(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Jalankan Tes Dio (Sukses)'),
            ),
            const SizedBox(height: 8),
            Obx(
              () =>
                  Text(controller.dioResult.value, textAlign: TextAlign.center),
            ),

            const Divider(height: 40),

            // ===========================================
            // --- BAGIAN 2: EKSPERIMEN ERROR & LOGGING ---
            // ===========================================
            const Text(
              'Analisis Error Handling & Logging',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // --- Tes Error HTTP ---
            ElevatedButton(
              onPressed: () => controller.isLoading.value
                  ? null
                  : controller.runHttpErrorTest(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
              child: const Text('Jalankan Tes Error HTTP'),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.httpErrorResult.value,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // --- Tes Error Dio ---
            ElevatedButton(
              onPressed: () => controller.isLoading.value
                  ? null
                  : controller.runDioErrorTest(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              child: const Text('Jalankan Tes Error Dio'),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.dioErrorResult.value,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[200],
              child: const Text(
                'PENTING: Cek "DEBUG CONSOLE" Anda setelah menekan tombol tes Dio. Anda akan melihat log lengkap request dan error secara otomatis.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

            // Indikator Loading Global
            const SizedBox(height: 20),
            Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
