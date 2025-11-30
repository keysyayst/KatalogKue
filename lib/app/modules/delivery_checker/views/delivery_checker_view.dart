import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/delivery_checker_controller.dart';
import '../../../data/sources/catering_info.dart';
import '../views/pickup_map_view.dart';

class DeliveryCheckerView extends GetView<DeliveryCheckerController> {
  const DeliveryCheckerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.customerLocation.value == null) {
          return _buildLocationError();
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeliveryToggle(),
                    _buildMapSection(),
                    _buildAddressCard(),
                    _buildDeliveryInfoCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ================= APP BAR (Simple & Clean) =================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Pesanan',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: controller.refreshLocation,
        ),
      ],
    );
  }

  // ================= DELIVERY TOGGLE (McD Style) =================
  Widget _buildDeliveryToggle() {
  return Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Row(
      children: [
        Expanded(
          child: _toggleButton(
            label: 'Ambil di Tempat',
            isSelected: false,
            onTap: () {
              // NAVIGASI KE HALAMAN PICKUP
              Get.to(() => const PickupMapView());
            },
          ),
        ),
        Expanded(
          child: _toggleButton(
            label: 'Pengiriman',
            isSelected: true,
            onTap: () {}, // Sudah di halaman ini
          ),
        ),
      ],
    ),
  );
}


  Widget _toggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFE8C00) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ================= MAP SECTION (Full Width) =================
  Widget _buildMapSection() {
    final storeLatLng = LatLng(
      CateringInfo.store['lat'],
      CateringInfo.store['lng'],
    );
    final customerLatLng = LatLng(
      controller.customerLocation.value!.latitude,
      controller.customerLocation.value!.longitude,
    );

    return Container(
      height: 300,
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          FlutterMap(
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
                    radius: CateringInfo.store['deliveryRadius'] * 1000,
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
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 24,
                      ),
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
                      child: const Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Floating distance badge
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        ],
      ),
    );
  }

  // ================= ADDRESS CARD (McD Style) =================
  Widget _buildAddressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFE8C00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: Color(0xFFFE8C00),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.locationMethod.value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Pengiriman dalam ${controller.estimatedTime.value} menit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  // ================= DELIVERY INFO CARD =================
  Widget _buildDeliveryInfoCard() {
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
              color: inZone ? Colors.black : Colors.red[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.getDeliveryMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Info rows
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _infoRow(
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
                    icon: Icons.local_shipping,
                    label: 'Biaya Ongkir',
                    value: controller.isFreeDelivery.value
                        ? 'GRATIS 🎉'
                        : 'Rp ${controller.deliveryCost.value.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (m) => '${m[1]}.',
                            )}',
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFFFE8C00),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // ================= LOADING STATE =================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFFE8C00),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Mencari lokasi Anda...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ERROR STATE =================
  Widget _buildLocationError() {
    return Center(
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
              'Mohon aktifkan GPS dan izinkan aplikasi mengakses lokasi Anda',
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
    );
  }
}