import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import '../controllers/location_experiment_controller.dart';

class LocationExperimentView extends StatelessWidget {
  const LocationExperimentView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Inject Controller
    final controller = Get.put(LocationExperimentController());

    // 2. Cek apakah sedang Mode Gelap
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 5: Location Aware'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // PANEL KONTROL
          Container(
            padding: const EdgeInsets.all(16),
            // 3. PERBAIKAN: Background menyesuaikan tema
            // Jika gelap pakai warna abu gelap, jika terang pakai putih
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Column(
              children: [
                // Teks Koordinat, Akurasi, Waktu
                Obx(
                  () => Text(
                    controller.address.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // 4. PERBAIKAN: Warna teks menyesuaikan tema
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Switch Provider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Provider: Network",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Obx(
                      () => Switch(
                        value: controller.isGpsMode.value,
                        onChanged: controller.toggleProvider,
                        activeTrackColor: const Color(0xFFFE8C00),
                        activeColor: Colors.white,
                      ),
                    ),
                    Text(
                      "GPS",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),

                // Tombol Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: controller.getLocationOneTime,
                      child: const Text("Get Loc"),
                    ),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLiveTracking.value
                            ? controller.stopTracking
                            : controller.startTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isLiveTracking.value
                              ? Colors.red
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          controller.isLiveTracking.value
                              ? "Stop Live"
                              : "Start Live",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MAPS SECTION
          Expanded(
            child: Obx(
              () => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.initialCenter,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.katalog.kue',
                  ),
                  if (controller.currentPosition.value != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: controller.currentPosition.value!,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  // Radius Akurasi (Visualisasi Modul 5)
                  if (controller.currentPosition.value != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: controller.currentPosition.value!,
                          radius: controller.accuracy.value,
                          useRadiusInMeter: true,
                          // Opacity disesuaikan agar terlihat bagus di peta
                          color: Colors.blue.withValues(alpha: 0.3),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
