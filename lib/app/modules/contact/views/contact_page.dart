import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

// Ubah dari StatelessWidget menjadi GetView<ContactController>
class ContactPage extends GetView<ContactController> {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hubungi Kami'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      // Gunakan SingleChildScrollView agar halaman bisa di-scroll
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BAGIAN INFO KONTAK (ASLI) ---
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
            const Divider(),

            // --- BAGIAN EKSPERIMEN (BARU) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Eksperimen Performa (HTTP vs Dio)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Tombol Tes HTTP
                  ElevatedButton(
                    // Gunakan Obx untuk men-disable tombol saat loading
                    onPressed: () => controller.isLoading.value
                        ? null
                        : controller.runHttpTest(),
                    child: const Text('Jalankan Tes HTTP'),
                  ),
                  const SizedBox(height: 8),
                  // Tampilkan hasil tes HTTP secara reaktif
                  Obx(
                    () => Text(
                      controller.httpResult.value,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Tes Dio
                  ElevatedButton(
                    onPressed: () => controller.isLoading.value
                        ? null
                        : controller.runDioTest(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Jalankan Tes DIO'),
                  ),
                  const SizedBox(height: 8),
                  // Tampilkan hasil tes Dio secara reaktif
                  Obx(
                    () => Text(
                      controller.dioResult.value,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Tampilkan loading indicator
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink(),
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
