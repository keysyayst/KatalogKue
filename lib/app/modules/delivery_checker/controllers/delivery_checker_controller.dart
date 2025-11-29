import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/location_service.dart';
import '../../../data/sources/catering_info.dart';
import '../../produk/controllers/produk_controller.dart';
import '../../../data/models/product.dart';

class DeliveryCheckerController extends GetxController {
  final LocationService locationService = Get.find<LocationService>();

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

  @override
  void onInit() {
    super.onInit();
    checkCustomerLocation();
  }

  // ================= TEXT UNTUK WHATSAPP =================

  String buildDeliveryText() {
    final jarak = distanceToStore.value.toStringAsFixed(2);
    final ongkir = isInDeliveryZone.value
        ? (isFreeDelivery.value
            ? 'GRATIS'
            : 'Rp ${deliveryCost.value.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]}.',
                )}')
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

  // ========================================
  // GET CUSTOMER LOCATION
  // ========================================

  Future<void> checkCustomerLocation() async {
    isLoading.value = true;

    try {
      // Coba GPS dulu
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

  // ========================================
  // CALCULATE DELIVERY INFO
  // ========================================

  void calculateDeliveryInfo() {
    if (customerLocation.value == null) return;

    final distance = locationService.calculateDistance(
      CateringInfo.store['lat'],
      CateringInfo.store['lng'],
      customerLocation.value!.latitude,
      customerLocation.value!.longitude,
    );

    distanceToStore.value = distance / 1000; // meter → km

    isInDeliveryZone.value =
        distanceToStore.value <= CateringInfo.store['deliveryRadius'];

    if (distanceToStore.value <= CateringInfo.store['freeDeliveryRadius']) {
      isFreeDelivery.value = true;
      deliveryCost.value = 0;
    } else {
      isFreeDelivery.value = false;
      final chargeableDistance =
          distanceToStore.value - CateringInfo.store['freeDeliveryRadius'];
      deliveryCost.value =
          (chargeableDistance * CateringInfo.store['deliveryCostPerKm'])
              .round();
    }

    estimatedTime.value = ((distanceToStore.value / 15) * 60).round();
  }

  // ========================================
  // REFRESH LOCATION
  // ========================================

  Future<void> refreshLocation() async {
    await checkCustomerLocation();
    Get.snackbar(
      'Lokasi Diperbarui',
      'Data lokasi berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ========================================
  // GET DELIVERY MESSAGE UNTUK CARD
  // ========================================

  String getDeliveryMessage() {
    if (!isInDeliveryZone.value) {
      return 'Maaf, lokasi Anda di luar area pengiriman (>${CateringInfo.store['deliveryRadius']} km)';
    } else if (isFreeDelivery.value) {
      return 'Selamat! Lokasi Anda mendapat GRATIS ONGKIR!';
    } else {
      return 'Ongkir: Rp ${deliveryCost.value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    }
  }

  // ========================================
  // OPEN WHATSAPP (dari halaman Delivery)
  // ========================================

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
      productInfo = """Produk: ${selectedProduct.title}
Harga: Rp ${selectedProduct.price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}
Jumlah: 1 pcs

""";
    } else {
      productInfo = "Produk: (belum dipilih dari aplikasi)\n\n";
    }

    final jarak = distanceToStore.value.toStringAsFixed(2);
    final ongkir = isInDeliveryZone.value
        ? (isFreeDelivery.value
            ? 'GRATIS'
            : 'Rp ${deliveryCost.value.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]}.',
                )}')
        : 'Di luar jangkauan';

    String lokasiText = '';
    if (lastLocationUrl.value.isNotEmpty) {
      lokasiText = '\nLokasi saya: ${lastLocationUrl.value}';
    }

    final message = Uri.encodeComponent(
      """Halo, saya ingin memesan kue.

$productInfo dari catering: $jarak km
Ongkir: $ongkir$lokasiText

Mohon konfirmasi ketersediaan dan total harga. Terima kasih.""",
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
        backgroundColor: const Color(0xFFFE8C00),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  // ========================================
  // OPEN GOOGLE MAPS (DIRECTIONS)
  // ========================================

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

  // ========================================
  // CALL PHONE
  // ========================================

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