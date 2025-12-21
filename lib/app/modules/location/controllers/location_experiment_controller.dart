import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
// Import Service Utama dari Aplikasi Fix
import '../../../data/services/location_service.dart';

class LocationExperimentController extends GetxController {
  // Mengambil instance LocationService yang sudah ada di memori (dari DashboardBinding)
  final LocationService _locationService = Get.find<LocationService>();

  final MapController mapController = MapController();

  // State UI
  var currentPosition = Rxn<LatLng>();
  var accuracy = 0.0.obs;
  var address = "Menunggu data lokasi...".obs;
  var isGpsMode = true.obs; // Toggle GPS vs Network
  var isLiveTracking = false.obs;

  StreamSubscription<Position>? _positionStream;

  // Initial Center (Default: Malang)
  final LatLng initialCenter = const LatLng(-7.9465, 112.6156);

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  void toggleProvider(bool value) {
    isGpsMode.value = value;
    stopTracking(); // Stop live tracking saat ganti mode
    Get.snackbar(
      "Mode Berubah",
      value
          ? "Menggunakan GPS (High Accuracy)"
          : "Menggunakan Network (Low Accuracy)",
      snackPosition: SnackPosition.BOTTOM,
    );
    getLocationOneTime(); // Refresh data sekali
  }

  Future<void> getLocationOneTime() async {
    address.value = "Mengambil lokasi...";

    Position? pos;

    // Menggunakan method dari LocationService utama Anda
    if (isGpsMode.value) {
      pos = await _locationService.getGPSLocation();
    } else {
      pos = await _locationService.getNetworkLocation();
    }

    if (pos != null) {
      _updateData(pos);
      // Pindahkan kamera peta ke lokasi baru
      mapController.move(LatLng(pos.latitude, pos.longitude), 16.0);
    } else {
      address.value = "Gagal mengambil lokasi. Cek GPS/Internet.";
    }
  }

  void startTracking() {
    isLiveTracking.value = true;

    // Menggunakan stream dari service utama
    _positionStream = _locationService.getLiveLocationStream().listen((pos) {
      _updateData(pos);
      // Ikuti pergerakan user di peta
      mapController.move(
        LatLng(pos.latitude, pos.longitude),
        mapController.camera.zoom,
      );
    });
  }

  void stopTracking() {
    isLiveTracking.value = false;
    _positionStream?.cancel();
  }

  void _updateData(Position pos) {
    currentPosition.value = LatLng(pos.latitude, pos.longitude);
    accuracy.value = pos.accuracy;

    DateTime time = pos.timestamp.toLocal();
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    String second = time.second.toString().padLeft(2, '0');
    String formattedTime = "$hour:$minute:$second";

    address.value =
        "Lat: ${pos.latitude.toStringAsFixed(5)}\n"
        "Lng: ${pos.longitude.toStringAsFixed(5)}\n"
        "Akurasi: ${pos.accuracy.toStringAsFixed(1)} m\n"
        "Waktu: $formattedTime";
  }
}
