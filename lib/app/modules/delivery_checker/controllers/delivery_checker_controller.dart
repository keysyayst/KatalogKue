import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';
import '../../../data/repositories/delivery_store_repository.dart';
import '../../../data/models/delivery_store_model.dart';
import '../../produk/controllers/produk_controller.dart';
import '../../../data/models/product.dart';
// IMPORT PENTING: Untuk memunculkan notifikasi lokal
import '../../notification/providers/local_notification_provider.dart';

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
  // Untuk kontrol posisi sheet (extent)
  final RxDouble sheetExtent = 0.38.obs;
  final LocationService locationService = Get.find<LocationService>();
  final DeliveryStoreRepository storeRepository = DeliveryStoreRepository();
  final Rx<DeliveryStore?> store = Rx<DeliveryStore?>(null);
  final MapController mapController = MapController();
  final Rx<Position?> customerLocation = Rx<Position?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInDeliveryZone = false.obs;
  final RxDouble distanceToStore = 0.0.obs;
  final RxInt deliveryCost = 0.obs;
  final RxBool isFreeDelivery = false.obs;
  final RxString locationMethod = ''.obs;
  final RxInt estimatedTime = 0.obs;
  final Rx<Position?> gpsLocation = Rx<Position?>(null);
  final Rx<Position?> networkLocation = Rx<Position?>(null);
  final RxDouble gpsAccuracy = 0.0.obs;
  final RxDouble networkAccuracy = 0.0.obs;
  final RxDouble locationDifference = 0.0.obs;
  final RxString lastLocationUrl = ''.obs;
  final RxBool isLiveTracking = false.obs;
  StreamSubscription<Position>? _positionStream;

  // --- FITUR BARU: STATE NOTIFIKASI BERTINGKAT ---
  final RxBool hasNotifiedFree =
      false.obs; // State untuk notif Zona Gratis Ongkir
  final RxBool hasNotifiedClose = false.obs; // State untuk notif Zona Dekat

  // Batas "Dekat" kita set 2 KM
  static const double thresholdCloseKm = 2.0;
  // -----------------------------------------------

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    await fetchStore();
    await checkCustomerLocation();
    isLoading.value = false;
  }

  Future<void> fetchStore() async {
    final stores = await storeRepository.getAllStores();
    store.value = stores.isNotEmpty ? stores.first : null;
  }

  @override
  void onClose() {
    stopLiveTracking();
    super.onClose();
  }

  // WA Logic
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
    final phone = store.value?.whatsapp ?? '';

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

  // Check Customer Location
  Future<void> checkCustomerLocation() async {
    try {
      Position? gpsPos = await locationService.getGPSLocation();

      if (gpsPos != null) {
        _setLocationFromGPS(gpsPos);
        Position? netPos = await locationService.getNetworkLocation();
        if (netPos != null) {
          _setNetworkComparison(gpsPos, netPos);
        }
      } else {
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

  // --- LOGIC KALKULASI UTAMA + TRIGGER NOTIFIKASI ---
  void calculateDeliveryInfo() {
    if (customerLocation.value == null) return;

    final storeLat = store.value?.latitude ?? 0.0;
    final storeLng = store.value?.longitude ?? 0.0;
    final deliveryRadius = store.value?.deliveryRadius ?? 0.0;
    final freeDeliveryRadius = store.value?.freeDeliveryRadius ?? 0.0;
    final costPerKm = (store.value?.deliveryCostPerKm ?? 0).toDouble();

    final distanceMeters = locationService.calculateDistance(
      storeLat,
      storeLng,
      customerLocation.value!.latitude,
      customerLocation.value!.longitude,
    );

    distanceToStore.value = distanceMeters / 1000;
    isInDeliveryZone.value = distanceToStore.value <= deliveryRadius;

    // Kalkulasi Biaya
    if (distanceToStore.value <= freeDeliveryRadius) {
      isFreeDelivery.value = true;
      deliveryCost.value = 0;
    } else {
      isFreeDelivery.value = false;
      final chargeableDistance = distanceToStore.value - freeDeliveryRadius;
      deliveryCost.value = (chargeableDistance * costPerKm).round();
    }

    estimatedTime.value = ((distanceToStore.value / 15) * 60).round();

    // --- CEK NOTIFIKASI ZONASI ---
    _checkZonedNotification();
  }

  // --- FUNGSI BARU: Logic Notifikasi Bertingkat ---
  void _checkZonedNotification() {
    final dist = distanceToStore.value;

    // Ambil radius gratis dari data toko (Default 5.0 km jika data null)
    // Ini membuat "Batas 5KM" menjadi dinamis sesuai settingan admin toko
    final double freeRadius = store.value?.freeDeliveryRadius ?? 5.0;

    // --- ZONA 1: SANGAT DEKAT (<= 2 KM) ---
    if (dist <= thresholdCloseKm) {
      if (!hasNotifiedClose.value) {
        _sendNotification(
          "Kamu sudah dekat! 🎂",
          "Kamu sudah dekat dengan toko! Mampir yuk.",
        );
        hasNotifiedClose.value = true;
        // Kita set free juga true agar tidak muncul double notif (close & free)
        hasNotifiedFree.value = true;
      }
    }
    // Reset jika menjauh > 2.5 KM
    else if (dist > (thresholdCloseKm + 0.5)) {
      hasNotifiedClose.value = false;
    }

    // --- ZONA 2: GRATIS ONGKIR (Antara 2 KM s/d Batas Gratis 5KM) ---
    // Logika: Jarak > 2KM (biar ga tabrakan sama notif dekat) TAPI masih <= Batas Gratis
    if (dist > thresholdCloseKm && dist <= freeRadius) {
      if (!hasNotifiedFree.value) {
        _sendNotification(
          "Gratis Ongkir Nih! 🚚",
          "Jarak kamu ${dist.toStringAsFixed(1)} km dari toko, dapet gratis ongkir nih",
        );
        hasNotifiedFree.value = true;
      }
    }
    // Reset jika menjauh dari batas gratis (+0.5 km buffer)
    else if (dist > (freeRadius + 0.5)) {
      hasNotifiedFree.value = false;
    }
  }

  void _sendNotification(String title, String body) {
    debugPrint('🔔 Sending Notification: $title');
    if (Get.isRegistered<LocalNotificationProvider>()) {
      Get.find<LocalNotificationProvider>().showNotification(
        title: title,
        body: body,
        payload: 'delivery',
      );
    }
  }
  // -----------------------------------------------------------

  void refreshStores() {
    if (customerLocation.value != null) {
      calculateDeliveryInfo();
    }
  }

  Future<void> refreshLocation() async {
    await checkCustomerLocation();
    Get.snackbar(
      'Lokasi Diperbarui',
      'Data lokasi berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void startLiveTracking() {
    if (isLiveTracking.value) return;
    isLiveTracking.value = true;

    _positionStream = locationService.getLiveLocationStream().listen((pos) {
      customerLocation.value = pos;
      calculateDeliveryInfo(); // Ini akan memanggil _checkZonedNotification secara live
      _moveCameraTo(pos);
    });
  }

  void stopLiveTracking() {
    isLiveTracking.value = false;
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> centerOnUser() async {
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

  String getDeliveryMessage() {
    if (!isInDeliveryZone.value) {
      return 'Maaf, lokasi Anda di luar area pengiriman (>${store.value?.deliveryRadius ?? 0} km)';
    } else if (isFreeDelivery.value) {
      return 'Selamat! Lokasi Anda mendapat GRATIS ONGKIR!';
    } else {
      return 'Ongkir: Rp ${deliveryCost.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }
  }

  StoreScheduleInfo getStoreSchedule() {
    final hours = store.value?.operationalHours;
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

    DateTime parseTime(String hhmm) {
      final pieces = hhmm.split(':');
      final h = int.parse(pieces.first);
      final m = pieces.length > 1 ? int.parse(pieces[1]) : 0;
      return DateTime(now.year, now.month, now.day, h, m);
    }

    final start = parseTime(startText);
    final end = endText.isEmpty ? start : parseTime(endText);
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

  // OPEN WHATSAPP
  Future<void> openWhatsApp() async {
    final phone = store.value?.whatsapp ?? '';
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

    // ignore: unused_local_variable
    final storeLat = store.value?.latitude ?? 0.0;
    // ignore: unused_local_variable
    final storeLng = store.value?.longitude ?? 0.0;

    // Menggunakan Google Maps Intent
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$storeLat,$storeLng';

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
    final phone = store.value?.phone ?? '';
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
