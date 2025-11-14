import 'package:get/get.dart';
import '../../../data/models/product.dart';
import 'produk_kami_controller.dart';

class ProductDetailController extends GetxController {
  final ProdukKamiController _produkKamiController =
      Get.find<ProdukKamiController>();

  final product = Rxn<Product>();
  final apiProductDetail = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    String? id = Get.parameters['id'];

    if (id != null) {
      // Cek apakah produk ada di data lokal
      final localProduct = _produkKamiController.getProductById(id);
      if (localProduct != null) {
        product.value = localProduct;
      } else {
        // Jika tidak, coba fetch dari API
        fetchApiProduct(id);
      }
    } else {
      Get.snackbar('Error', 'ID Produk tidak valid');
      Get.back();
    }
  }

  Future<void> fetchApiProduct(String id) async {
    try {
      isLoading.value = true;
      final result = await _produkKamiController.fetchApiMealDetail(id);
      if (result != null) {
        apiProductDetail.value = result;
      } else {
        Get.snackbar('Error', 'Produk dari API tidak ditemukan');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }
}
