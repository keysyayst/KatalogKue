import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/eksperimen_controller.dart';

class EksperimenView extends GetView<EksperimenController> {
  const EksperimenView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController ingredientController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksperimen & Tes API'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tes Performa (HTTP vs Dio)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.runHttpTest(),
                child: const Text('Jalankan Tes HTTP (Sukses)'),
              ),
            ),
            Obx(
              () => Text(
                controller.httpResult.value,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.runDioTest(),
                child: const Text('Jalankan Tes Dio (Sukses)'),
              ),
            ),
            Obx(
              () =>
                  Text(controller.dioResult.value, textAlign: TextAlign.center),
            ),
            const Divider(height: 32),
            const Text(
              'Tes Penanganan Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.runHttpErrorTest(),
                child: const Text('Jalankan Tes Error HTTP'),
              ),
            ),
            Obx(
              () => Text(
                controller.httpErrorResult.value,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.runDioErrorTest(),
                child: const Text('Jalankan Tes Error Dio'),
              ),
            ),
            Obx(
              () => Text(
                controller.dioErrorResult.value,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Tes Async & Chained Request',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ingredientController,
              decoration: const InputDecoration(
                labelText: 'Masukkan Bahan (misal: chicken)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.runAsyncAwaitTest(
                        ingredientController.text,
                      ),
                child: const Text('Tes Async/Await'),
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () =>
                          controller.runCallbackTest(ingredientController.text),
                child: const Text('Tes .then() Chaining'),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[200],
                child: Text(
                  controller.asyncResult.value,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.runChainedRequestTest(),
                child: const Text('Tes Chained Request'),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue[50],
                child: Text(
                  controller.chainedResult.value,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
