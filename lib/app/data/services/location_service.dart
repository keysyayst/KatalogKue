import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class LocationService extends GetxService {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxString locationSource = ''.obs;
  final RxBool isGPSEnabled = false.obs;
  final RxDouble accuracy = 0.0.obs;
  final RxBool isLocationPermissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLocationPermission();
  }

  // PERMISSION HANDLING

  Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    isLocationPermissionGranted.value = status.isGranted;
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    isLocationPermissionGranted.value = status.isGranted;
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    
    return status.isGranted;
  }

  // GPS LOCATION (HIGH ACCURACY)

  Future<Position?> getGPSLocation() async {
    try {
      // Check if location service enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'GPS Nonaktif',
          'Mohon aktifkan GPS untuk akurasi tinggi',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Lokasi Ditolak',
          'Mohon izinkan akses lokasi di pengaturan aplikasi',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      locationSource.value = 'GPS';
      accuracy.value = position.accuracy;
      currentPosition.value = position;
      isGPSEnabled.value = true;

      developer.log(
        'GPS Location: ${position.latitude}, ${position.longitude} | Accuracy: ${position.accuracy}m',
        name: 'LocationService',
      );

      return position;
    } catch (e) {
      developer.log('GPS Error: $e', name: 'LocationService', error: e);
      Get.snackbar(
        'GPS Error',
        'Tidak dapat mengakses GPS: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // NETWORK LOCATION (LOWER ACCURACY)

  Future<Position?> getNetworkLocation() async {
    try {
      loc.Location location = loc.Location();

      // Check if service enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      // Check permission
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          return null;
        }
      }

      // Get location
      loc.LocationData locationData = await location.getLocation();

      Position position = Position(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        timestamp: DateTime.now(),
        accuracy: locationData.accuracy!,
        altitude: locationData.altitude ?? 0,
        heading: locationData.heading ?? 0,
        speed: locationData.speed ?? 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      locationSource.value = 'Network';
      accuracy.value = position.accuracy;
      currentPosition.value = position;
      isGPSEnabled.value = false;

      developer.log(
        'Network Location: ${position.latitude}, ${position.longitude} | Accuracy: ${position.accuracy}m',
        name: 'LocationService',
      );

      return position;
    } catch (e) {
      developer.log('Network Location Error: $e', name: 'LocationService', error: e);
      return null;
    }
  }

  // SMART LOCATION (GPS FIRST, FALLBACK TO NETWORK)

  Future<Position?> getCurrentLocation() async {
    // Try GPS first
    Position? position = await getGPSLocation();

    // Fallback to Network if GPS fails
    position ??= await getNetworkLocation();

    return position;
  }

  // LIVE LOCATION STREAM

  Stream<Position> getLiveLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // CALCULATE DISTANCE

  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // FORMAT DISTANCE

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  // CALCULATE BEARING (DIRECTION)

  double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }
}
