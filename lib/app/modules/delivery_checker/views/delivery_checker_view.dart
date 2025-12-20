import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/delivery_checker_controller.dart';
import '../../../app.dart';

class DeliveryCheckerView extends GetView<DeliveryCheckerController> {
  const DeliveryCheckerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.customerLocation.value == null) {
          return _buildLocationError();
        }

        return Stack(
          children: [
            // Full screen map background
            Positioned.fill(child: _buildFullMap()),

            // Top overlay (acts like AppBar but translucent)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE8C00),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          try {
                            final dash = Get.find<DashboardController>();
                            dash.changeTabIndex(0);
                          } catch (e) {
                            Get.back();
                          }
                        },
                      ),
                    ),
                    // Hapus kotak putih dan tulisan 'Pesanan'
                  ],
                ),
              ),
            ),

            // Floating controls and distance badge (hanya tampil jika sheetExtent <= 0.5)
            Obx(() {
              if (controller.sheetExtent.value > 0.5)
                return const SizedBox.shrink();

              // Hitung posisi bottom dinamis mengikuti sheetExtent
              final double sheetBottom =
                  MediaQuery.of(context).size.height *
                      controller.sheetExtent.value +
                  16;

              return Stack(
                children: [
                  Positioned(
                    left: 16,
                    bottom: sheetBottom,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.straighten,
                            color: Color(0xFFFE8C00),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${controller.distanceToStore.value.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: sheetBottom,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'centerMe',
                          onPressed: () async {
                            if (!controller.isLiveTracking.value) {
                              controller.startLiveTracking();
                            }
                            await controller.centerOnUser();
                          },
                          backgroundColor: Colors.white,
                          elevation: 3,
                          child: const Icon(
                            Icons.my_location,
                            color: Color(0xFFFE8C00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),

            // Draggable bottom sheet with details
            DraggableScrollableSheet(
              initialChildSize: 0.38,
              minChildSize: 0.18,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    controller.sheetExtent.value = notification.extent;
                    return false;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // drag handle
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          // content
                          const SizedBox(height: 8),
                          _buildStoreInfoCard(),
                          _buildAddressCard(isDark),
                          _buildDeliveryInfoCard(isDark),
                          _buildHelpSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  // Full screen map used as background for draggable sheet layout
  Widget _buildFullMap() {
    final storeLatLng = LatLng(
      controller.store.value?.latitude ?? 0.0,
      controller.store.value?.longitude ?? 0.0,
    );
    final customerLatLng = LatLng(
      controller.customerLocation.value!.latitude,
      controller.customerLocation.value!.longitude,
    );

    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: storeLatLng,
        initialZoom: 12.5,
        minZoom: 10,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.katalog',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: storeLatLng,
              radius: (controller.store.value?.deliveryRadius ?? 0.0) * 1000,
              useRadiusInMeter: true,
              color: const Color(0xFFFE8C00).withOpacity(0.1),
              borderColor: const Color(0xFFFE8C00),
              borderStrokeWidth: 2,
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [storeLatLng, customerLatLng],
              strokeWidth: 3,
              color: const Color(0xFFFE8C00),
              pattern: const StrokePattern.dotted(spacingFactor: 2),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: storeLatLng,
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFE8C00),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.store, color: Colors.white, size: 24),
              ),
            ),
            Marker(
              point: customerLatLng,
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.circle, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  //STORE INFO CARD
  Widget _buildStoreInfoCard() {
    final store = controller.store.value;

    if (store == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFE8C00).withOpacity(0.1),
            const Color(0xFFFE8C00).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFE8C00).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFE8C00), Color(0xFFFF6B00)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFE8C00),
                      ),
                    ),
                    Text(
                      'Pemilik: ${store.owner}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStoreInfoRow(
            icon: Icons.location_on_rounded,
            label: 'Alamat',
            value: store.address,
          ),
          const SizedBox(height: 8),
          _buildStoreInfoRow(
            icon: Icons.phone_rounded,
            label: 'Telepon',
            value: store.phone,
          ),
          const SizedBox(height: 8),
          _buildStoreInfoRow(
            icon: Icons.chat_rounded,
            label: 'WhatsApp',
            value: store.whatsapp,
          ),
          const SizedBox(height: 8),
          _buildStoreInfoRow(
            icon: Icons.email_rounded,
            label: 'Email',
            value: store.email,
          ),
          const SizedBox(height: 8),
          // ====== Jam Operasional Dinamis (Urut Hari) ======
          if (store.operationalHours != null &&
              store.operationalHours!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jam Operasional',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFFE8C00),
                  ),
                ),
                const SizedBox(height: 4),
                ...[
                  'Senin',
                  'Selasa',
                  'Rabu',
                  'Kamis',
                  'Jumat',
                  'Sabtu',
                  'Minggu',
                ].map((hari) {
                  final data = store.operationalHours![hari];
                  final open = data != null ? (data['open'] ?? '-') : '-';
                  final close = data != null ? (data['close'] ?? '-') : '-';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(width: 80, child: Text(hari)),
                        const SizedBox(width: 8),
                        Text('Buka: $open'),
                        const SizedBox(width: 12),
                        Text('Tutup: $close'),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          // ====== END Jam Operasional Dinamis ======
        ],
      ),
    );
  }

  Widget _buildStoreInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFE8C00).withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFFFE8C00)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= ADDRESS CARD =================
  Widget _buildAddressCard(bool isDark) {
    // Address card dihilangkan total agar tidak ada kotak kosong GPS
    return const SizedBox.shrink();
  }

  // ================= DELIVERY INFO CARD =================
  Widget _buildDeliveryInfoCard(bool isDark) {
    final inZone = controller.isInDeliveryZone.value;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: inZone
            ? const Color(0xFFFE8C00).withOpacity(0.08)
            : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inZone
              ? const Color(0xFFFE8C00).withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            inZone ? Icons.check_circle : Icons.cancel,
            size: 64,
            color: inZone ? const Color(0xFFFE8C00) : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            inZone ? 'Lokasi Terjangkau!' : 'Di Luar Jangkauan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: inZone
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.red[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.getDeliveryMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Info rows
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _infoRow(
                  isDark: isDark,
                  icon: Icons.access_time,
                  label: 'Estimasi Waktu',
                  value: '~${controller.estimatedTime.value} menit',
                ),
                if (inZone) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _infoRow(
                    isDark: isDark,
                    icon: Icons.local_shipping,
                    label: 'Biaya Ongkir',
                    value: controller.isFreeDelivery.value
                        ? 'GRATIS 🎉'
                        : 'Rp ${controller.deliveryCost.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.chat_bubble,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: controller.openWhatsApp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.phone,
                  label: 'Telepon',
                  color: const Color(0xFF2196F3),
                  onTap: controller.callPhone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: controller.openGoogleMaps,
              icon: const Icon(Icons.directions, size: 22),
              label: const Text(
                'Buka Petunjuk Arah',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE8C00),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELP / FAQ =================
  Widget _buildHelpSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFFFE8C00)),
              SizedBox(width: 8),
              Text(
                'Bantuan Pengiriman',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 12),
          _HelpBullet(
            text: 'Pastikan GPS aktif untuk hitung jarak dan ongkir.',
          ),
          _HelpBullet(
            text:
                'Di luar radius? Hubungi kami via WhatsApp untuk opsi pengambilan.',
          ),
          _HelpBullet(
            text:
                'Tombol Arah membuka Google Maps sesuai lokasi Anda sekarang.',
          ),
          _HelpBullet(
            text:
                'Jam buka mengikuti jadwal toko; pesan lebih awal saat ramai.',
          ),
        ],
      ),
    );
  }

  // Simple help bullet widget to keep text compact
  // (intentionally stateless and small)

  // ================= LOADING STATE =================
  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFE8C00), strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              'Memuat peta...',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ERROR STATE =================
  Widget _buildLocationError() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tidak dapat mengakses lokasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Mohon aktifkan GPS untuk melihat lokasi toko',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: controller.refreshLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE8C00),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]
                : const Color(0xFFFE8C00).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white70 : const Color(0xFFFE8C00),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _HelpBullet extends StatelessWidget {
  final String text;

  const _HelpBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.black87)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
