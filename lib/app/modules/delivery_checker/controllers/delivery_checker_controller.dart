import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/services/location_service.dart';
import '../../../data/sources/catering_info.dart';
import '../../../data/models/delivery_store_model.dart';
import '../../../data/repositories/delivery_store_repository.dart';
import '../../produk/controllers/produk_controller.dart';
import '../../../data/models/product.dart';

class DeliveryCheckerController extends GetxController {
  final LocationService locationService = Get.find<LocationService>();
  final DeliveryStoreRepository _storeRepository = DeliveryStoreRepository();

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

  // Multi-store support (NEW)
  final RxList<DeliveryStore> availableStores = RxList<DeliveryStore>([]);
  final Rx<DeliveryStore?> selectedStore = Rx<DeliveryStore?>(null);
  final RxBool storesLoading = false.obs;

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
  RealtimeChannel? _storesChannel;

  @override
  void onInit() {
    super.onInit();
    _loadAvailableStores();
    checkCustomerLocation();
    _setupRealtimeSubscription();
  }

  /// Load all available delivery stores from repository
  Future<void> _loadAvailableStores() async {
    storesLoading.value = true;
    try {
      final stores = await _storeRepository.getAllStores();
      availableStores.assignAll(stores);

      // Set first store as default if available
      if (stores.isNotEmpty) {
        selectedStore.value = stores.first;
      }
    } catch (e) {
      print('❌ Error loading stores: $e');
    } finally {
      storesLoading.value = false;
    }
  }

  /// Select store and recalculate delivery info
  void selectStore(DeliveryStore store) {
    selectedStore.value = store;
    calculateDeliveryInfo();
    // Pindahkan kamera ke lokasi toko baru
    try {
      mapController.move(
        LatLng(store.latitude, store.longitude),
        mapController.camera.zoom,
      );
    } catch (_) {}
  }

  @override
  void onClose() {
    stopLiveTracking();
    _storesChannel?.unsubscribe();
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

    final store = selectedStore.value;
    final storeLat = store?.latitude ?? CateringInfo.store['lat'];
    final storeLng = store?.longitude ?? CateringInfo.store['lng'];
    final deliveryRadius =
        store?.deliveryRadius ?? CateringInfo.store['deliveryRadius'];
    final freeDeliveryRadius =
        store?.freeDeliveryRadius ?? CateringInfo.store['freeDeliveryRadius'];
    final costPerKm =
        (store?.deliveryCostPerKm ?? CateringInfo.store['deliveryCostPerKm'])
            .toDouble();

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

// refresh location and stores
  Future<void> refreshLocation() async {
    await _loadAvailableStores();
    await checkCustomerLocation();
    Get.snackbar(
      'Lokasi Diperbarui',
      'Data lokasi berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  Future<void> refreshStores() async {
    await _loadAvailableStores();
    Get.snackbar(
      'Toko Diperbarui',
      'Daftar toko berhasil dimuat ulang',
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
    } catch (_) {
    }
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
    final store = selectedStore.value;
    final storeLat = store?.latitude ?? CateringInfo.store['lat'];
    final storeLng = store?.longitude ?? CateringInfo.store['lng'];
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

  // REALTIME SUBSCRIPTION TO STORES TABLE
  void _setupRealtimeSubscription() {
    try {
      final client = Supabase.instance.client;
      _storesChannel = client.channel('public:delivery_stores')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'delivery_stores',
          callback: (payload) {
            refreshStores();
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('Realtime subscription error: $e');
    }
  }
}
