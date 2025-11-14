import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/sources/products.dart';
import '../../../data/services/nutrition_service.dart';
import '../../../data/models/nutrition_model.dart';


class ProdukController extends GetxController {
  final ProductService productService = Get.find<ProductService>();
  final NutritionService nutritionService = Get.find<NutritionService>();
  
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var searchQuery = ''.obs;
  
  // Untuk detail produk
  var selectedProduct = Rx<Product?>(null);
  var nutritionData = Rx<NutritionData?>(null);
  var isLoadingNutrition = false.obs;
  var currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    products.value = productService.getAllProducts();
    filteredProducts.value = products;
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products.where((product) {
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
               product.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> loadNutritionData(String productName) async {
    try {
      isLoadingNutrition(true);
      //debugPrint('🍰 Loading nutrition for: $productName');
      
      final data = await nutritionService.getNutritionData(productName);
      nutritionData.value = data;
      
      //print('✅ Nutrition loaded successfully');
    } catch (e) {
      //print('❌ Error loading nutrition: $e');
      nutritionData.value = NutritionData.dummy();
    } finally {
      isLoadingNutrition(false);
    }
  }

  void selectProduct(Product product) {
    selectedProduct.value = product;
    loadNutritionData(product.title);
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    
    // Load nutrition data saat tab nutrisi dibuka
    if (index == 2 && selectedProduct.value != null && nutritionData.value == null) {
      loadNutritionData(selectedProduct.value!.title);
    }
  }
}
