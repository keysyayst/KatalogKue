import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        backgroundColor: const Color(0xFFFE8C00),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Rekomendasi Harian',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Pagi, siang, sore, malam'),
                ),
                Obx(() => SwitchListTile(
                  value: controller.moodEnabled.value,
                  onChanged: controller.toggleMood,
                  title: const Text('Aktifkan'),
                  activeColor: const Color(0xFFFE8C00),
                )),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  title: const Text('🎉 Promo & Diskon',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Flash sale, penawaran spesial'),
                ),
                Obx(() => SwitchListTile(
                  value: controller.promoEnabled.value,
                  onChanged: controller.togglePromo,
                  title: const Text('Aktifkan'),
                  activeColor: const Color(0xFFFE8C00),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}