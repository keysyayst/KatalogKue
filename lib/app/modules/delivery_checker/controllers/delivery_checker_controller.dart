import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';
import '../../../data/sources/catering_info.dart';
import '../../produk/controllers/produk_controller.dart';
import '../../../data/models/product.dart';

class StoreScheduleInfo {
  final bool isOpen;
  final String statusLabel;
  final String hoursText;

  const StoreScheduleInfo({
    required this.isOpen,
    required this.statusLabel,
    required this.hoursText,
  });
}

class DeliveryCheckerController extends GetxController {
  final LocationService locationService = Get.find<LocationService>();

  // Map controller to control camera programmatically
  final MapController mapController = MapController();

  // Observables lokasi & ongkir
  final Rx<Position?> customerLocation = Rx<Position?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInDeliveryZone = false.obs;
  final RxDouble distanceToStore = 0.0.obs;
  final RxInt deliveryCost = 0.obs;
  final RxBool isFreeDelivery = false.obs;
  final RxString locationMethod = ''.obs;
  final RxInt estimatedTime = 0.obs;

  // Perbandingan GPS vs Network
  final Rx<Position?> gpsLocation = Rx<Position?>(null);
  final Rx<Position?> networkLocation = Rx<Position?>(null);
  final RxDouble gpsAccuracy = 0.0.obs;
  final RxDouble networkAccuracy = 0.0.obs;
  final RxDouble locationDifference = 0.0.obs;

  // Lokasi terakhir sebagai URL Google Maps
  final RxString lastLocationUrl = ''.obs;

  // Live tracking state & subscription
  final RxBool isLiveTracking = false.obs;
  StreamSubscription<Position>? _positionStream;

  @override
  void onInit() {
    super.onInit();
    checkCustomerLocation();
  }

  @override
  void onClose() {
    stopLiveTracking();
    super.onClose();
  }

  //WA
  String buildDeliveryText() {
    final jarak = distanceToStore.value.toStringAsFixed(2);
    final ongkir = isInDeliveryZone.value
        ? (isFreeDelivery.value
              ? 'GRATIS'
              : 'Rp ${deliveryCost.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}')
        : 'Di luar jangkauan';

    String lokasiText = '';
    if (lastLocationUrl.value.isNotEmpty) {
      lokasiText = '\nLokasi saya: ${lastLocationUrl.value}';
    }

    return 'Jarak dari catering: $jarak km\n'
        'Ongkir: $ongkir$lokasiText';
  }

  Future<void> openWhatsAppWithProduct(Product product) async {
    final phone = CateringInfo.store['whatsapp'];

    final deliveryText = buildDeliveryText();

    final message = Uri.encodeComponent(
      'Halo, saya ingin memesan ${product.title} '
      'dengan harga Rp ${product.price}.\n'
      '$deliveryText\n\n'
      'Mohon konfirmasi ketersediaan dan total harga. Terima kasih.',
    );

    final url = 'https://wa.me/$phone?text=$message';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'WhatsApp Tidak Tersedia',
        'Pastikan WhatsApp terinstall di perangkat Anda',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  //get customer location
  Future<void> checkCustomerLocation() async {
    isLoading.value = true;

    try {
      Position? gpsPos = await locationService.getGPSLocation();

      if (gpsPos != null) {
        _setLocationFromGPS(gpsPos);

        // Ambil network untuk perbandingan
        Position? netPos = await locationService.getNetworkLocation();
        if (netPos != null) {
          _setNetworkComparison(gpsPos, netPos);
        }
      } else {
        // Fallback ke Network
        Position? netPos = await locationService.getNetworkLocation();
        if (netPos != null) {
          _setLocationFromNetwork(netPos);
        } else {
          Get.snackbar(
            'Lokasi Tidak Tersedia',
            'Mohon aktifkan GPS atau koneksi internet',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }

      if (customerLocation.value != null) {
        calculateDeliveryInfo();

        _moveCameraTo(customerLocation.value!);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _setLocationFromGPS(Position gpsPos) {
    customerLocation.value = gpsPos;
    gpsLocation.value = gpsPos;
    gpsAccuracy.value = gpsPos.accuracy;
    locationMethod.value = 'GPS (Akurasi Tinggi)';

    lastLocationUrl.value =
        'https://www.google.com/maps/search/?api=1&query=${gpsPos.latitude},${gpsPos.longitude}';
  }

  void _setNetworkComparison(Position gpsPos, Position netPos) {
    networkLocation.value = netPos;
    networkAccuracy.value = netPos.accuracy;
    locationDifference.value = locationService.calculateDistance(
      gpsPos.latitude,
      gpsPos.longitude,
      netPos.latitude,
      netPos.longitude,
    );
  }

  void _setLocationFromNetwork(Position netPos) {
    customerLocation.value = netPos;
    networkLocation.value = netPos;
    networkAccuracy.value = netPos.accuracy;
    locationMethod.value = 'Network (Estimasi)';

    lastLocationUrl.value =
        'https://www.google.com/maps/search/?api=1&query=${netPos.latitude},${netPos.longitude}';
  }

  //calculate delivery info
  void calculateDeliveryInfo() {
    if (customerLocation.value == null) return;

    final storeLat = CateringInfo.store['lat'];
    final storeLng = CateringInfo.store['lng'];
    final deliveryRadius = CateringInfo.store['deliveryRadius'];
    final freeDeliveryRadius = CateringInfo.store['freeDeliveryRadius'];
    final costPerKm = (CateringInfo.store['deliveryCostPerKm']).toDouble();

    final distanceMeters = locationService.calculateDistance(
      storeLat,
      storeLng,
      customerLocation.value!.latitude,
      customerLocation.value!.longitude,
    );

    distanceToStore.value = distanceMeters / 1000; // meter -> km

    isInDeliveryZone.value = distanceToStore.value <= deliveryRadius;

    if (distanceToStore.value <= freeDeliveryRadius) {
      isFreeDelivery.value = true;
      deliveryCost.value = 0;
    } else {
      isFreeDelivery.value = false;
      final chargeableDistance = distanceToStore.value - freeDeliveryRadius;
      deliveryCost.value = (chargeableDistance * costPerKm).round();
    }

    estimatedTime.value = ((distanceToStore.value / 15) * 60).round();
  }

  /// Called when stores list is updated elsewhere (e.g. admin changes).
  /// Recalculates delivery info using the current customer location and
  /// available store data. This is intentionally lightweight—if more
  /// complex refresh logic is needed, expand this implementation.
  void refreshStores() {
    if (customerLocation.value != null) {
      calculateDeliveryInfo();
    }
  }

  // refresh location and stores
  Future<void> refreshLocation() async {
    await checkCustomerLocation();
    Get.snackbar(
      'Lokasi Diperbarui',
      'Data lokasi berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // live tracking control
  void startLiveTracking() {
    if (isLiveTracking.value) return;
    isLiveTracking.value = true;

    _positionStream = locationService.getLiveLocationStream().listen((pos) {
      customerLocation.value = pos;
      calculateDeliveryInfo();
      _moveCameraTo(pos);
    });

    Get.snackbar(
      'Live Location Aktif',
      'Peta mengikuti pergerakan Anda',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void stopLiveTracking() {
    isLiveTracking.value = false;
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> centerOnUser() async {
    // If we don't have a location yet, fetch once
    if (customerLocation.value == null) {
      await checkCustomerLocation();
    }
    final pos = customerLocation.value;
    if (pos != null) {
      _moveCameraTo(pos);
    }
  }

  void _moveCameraTo(Position pos) {
    try {
      mapController.move(
        LatLng(pos.latitude, pos.longitude),
        mapController.camera.zoom,
      );
    } catch (_) {}
  }

  // GET DELIVERY MESSAGE UNTUK CARD
  String getDeliveryMessage() {
    if (!isInDeliveryZone.value) {
      return 'Maaf, lokasi Anda di luar area pengiriman (>${CateringInfo.store['deliveryRadius']} km)';
    } else if (isFreeDelivery.value) {
      return 'Selamat! Lokasi Anda mendapat GRATIS ONGKIR!';
    } else {
      return 'Ongkir: Rp ${deliveryCost.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }
  }

  StoreScheduleInfo getStoreSchedule() {
    final hours =
        CateringInfo.store['operationalHours'] as Map<String, dynamic>?;
    final now = DateTime.now();
    final dayKey = _mapDayToKey(now.weekday);
    final rawHours = hours?[dayKey]?.toString();

    if (rawHours == null || rawHours.toLowerCase() == 'tutup') {
      return const StoreScheduleInfo(
        isOpen: false,
        statusLabel: 'Tutup',
        hoursText: 'Tutup hari ini',
      );
    }

    final parts = rawHours.split(' - ');
    final startText = parts.first;
    final endText = parts.length > 1 ? parts.last : '';

    DateTime _parse(String hhmm) {
      final pieces = hhmm.split(':');
      final h = int.parse(pieces.first);
      final m = pieces.length > 1 ? int.parse(pieces[1]) : 0;
      return DateTime(now.year, now.month, now.day, h, m);
    }

    final start = _parse(startText);
    final end = endText.isEmpty ? start : _parse(endText);
    final isOpen = now.isAfter(start) && now.isBefore(end);

    final statusLabel = isOpen ? 'Buka sekarang' : 'Tutup sekarang';
    final hoursText = isOpen ? 'Tutup pukul $endText' : 'Buka pukul $startText';

    return StoreScheduleInfo(
      isOpen: isOpen,
      statusLabel: statusLabel,
      hoursText: hoursText,
    );
  }

  String _mapDayToKey(int weekday) {
    if (weekday >= DateTime.monday && weekday <= DateTime.friday) {
      return 'senin-jumat';
    }
    if (weekday == DateTime.saturday) return 'sabtu';
    return 'minggu';
  }

  // OPEN WHATSAPP (dari halaman delivery)
  Future<void> openWhatsApp() async {
    final phone = CateringInfo.store['whatsapp'];

    // Produk terpilih (jika ada)
    Product? selectedProduct;
    if (Get.isRegistered<ProdukController>()) {
      final produkController = Get.find<ProdukController>();
      selectedProduct = produkController.selectedProduct.value;
    }

    String productInfo;
    if (selectedProduct != null) {
      productInfo =
          """Produk: ${selectedProduct.title}
          Harga: Rp ${selectedProduct.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}
          Jumlah: 1 pcs""";
    } else {
      productInfo = "Produk: (belum dipilih dari aplikasi)\n\n";
    }

    final jarak = distanceToStore.value.toStringAsFixed(2);
    final ongkir = isInDeliveryZone.value
        ? (isFreeDelivery.value
              ? 'GRATIS'
              : 'Rp ${deliveryCost.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}')
        : 'Di luar jangkauan';

    String lokasiText = '';
    if (lastLocationUrl.value.isNotEmpty) {
      lokasiText = '\nLokasi saya: ${lastLocationUrl.value}';
    }

    final message = Uri.encodeComponent("""Halo, saya ingin memesan kue.

$productInfo dari catering: $jarak km
Ongkir: $ongkir$lokasiText

Mohon konfirmasi ketersediaan dan total harga. Terima kasih.""");

    final url = 'https://wa.me/$phone?text=$message';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'WhatsApp Tidak Tersedia',
        'Pastikan WhatsApp terinstall di perangkat Anda',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFE8C00),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  // OPEN GOOGLE MAPS (DIRECTIONS)
  Future<void> openGoogleMaps() async {
    if (customerLocation.value == null) return;
    final storeLat = CateringInfo.store['lat'];
    final storeLng = CateringInfo.store['lng'];
    final customerLat = customerLocation.value!.latitude;
    final customerLng = customerLocation.value!.longitude;

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$customerLat,$customerLng&destination=$storeLat,$storeLng&travelmode=driving';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Tidak dapat membuka Google Maps',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // CALL PHONE
  Future<void> callPhone() async {
    final phone = CateringInfo.store['phone'];
    final url = 'tel:$phone';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Error',
        'Tidak dapat melakukan panggilan',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
