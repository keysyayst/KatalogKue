import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // Dapatkan instance ContactController
  final ContactController controller = Get.find<ContactController>();
  // Buat TextEditingController untuk input
  final TextEditingController ingredientController = TextEditingController();

  @override
  void dispose() {
    // dispose controller textfield
    ingredientController.dispose();
    super.dispose();
  }

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
            // --- Info Kontak ---
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

            // --- Eksperimen Performa (Tugas 1) ---
            const Text(
              'Eksperimen Performa (Tugas 1)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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

            // --- Analisis Error Handling & Logging (Tugas 2) ---
            const Text(
              'Analisis Error Handling & Logging',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
                'PENTING: Cek "DEBUG CONSOLE" Anda setelah menekan tombol tes Dio.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

            const Divider(height: 40),

            // --- BAGIAN 3: EKSPERIMEN ASYNC HANDLING (DENGAN INPUT) ---
            const Text(
              'Eksperimen Async Handling',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Skenario: Cari Resep via API berdasarkan Bahan dari Input',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // --- Input Field ---
            TextField(
              controller: ingredientController, // Gunakan controller
              decoration: const InputDecoration(
                labelText: 'Masukkan Bahan (Contoh: Chicken, Eggs, Flour)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // --- Tombol Tes Async/Await ---
            ElevatedButton(
              onPressed: () {
                // Ambil teks dari input field
                final String ingredient = ingredientController.text;
                // Jalankan tes jika tidak sedang loading
                if (!controller.isLoading.value) {
                  controller.runAsyncAwaitTest(
                    ingredient,
                  ); // Kirim ingredient ke controller
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Cari via Async / Await'),
            ),
            const SizedBox(height: 16),

            // --- Tombol Tes .then() Chaining ---
            ElevatedButton(
              onPressed: () {
                // Ambil teks dari input field
                final String ingredient = ingredientController.text;
                // Jalankan tes jika tidak sedang loading
                if (!controller.isLoading.value) {
                  controller.runCallbackTest(
                    ingredient,
                  ); // Kirim ingredient ke controller
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[300],
              ),
              child: const Text('Cari via .then() Chaining'),
            ),
            const SizedBox(height: 16),

            // --- Hasil Tes Async ---
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Obx(
                () => Text(
                  controller.asyncResult.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Indikator Loading Global
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
