import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/produk_controller.dart';
import '../../../data/models/product.dart';
import '../../delivery_checker/controllers/delivery_checker_controller.dart';


class DetailProdukPage extends GetView<ProdukController> {
  const DetailProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = controller.selectedProduct.value!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
          backgroundColor: const Color(0xFFFE8C00),
          foregroundColor: Colors.white,
          bottom: TabBar(
            onTap: controller.changeTab,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Deskripsi'),
              Tab(text: 'Komposisi'),
              Tab(text: 'Nutrisi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDescriptionTab(product, isDark),
            _buildCompositionTab(product, isDark),
            _buildNutritionTab(isDark),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(product),
      ),
    );
  }

  Widget _buildDescriptionTab(product, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.image.startsWith('http')
                ? Image.network(
                    product.image,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text('Gambar tidak tersedia'),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFE8C00),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    product.image,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text('Gambar tidak tersedia'),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),

          // Price
          Text(
            'Rp. ${product.price}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFE8C00),
            ),
          ),

          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFFFE8C00)),
              const SizedBox(width: 4),
              Text(
                product.location,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // Description
          Text(
            'Deskripsi Produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          if (product.description != null && product.description!.isNotEmpty)
            Text(
              product.description!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Deskripsi produk belum tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompositionTab(product, bool isDark) {
    final List<String> ingredients = product.compositionList;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komposisi Bahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          if (ingredients.isNotEmpty)
            ...ingredients
                .map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Color(0xFFFE8C00),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList()
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Komposisi bahan belum tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (ingredients.isNotEmpty) const SizedBox(height: 16),

          if (ingredients.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFE8C00)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dibuat dengan bahan berkualitas dan proses higienis',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab(bool isDark) {
    final product = controller.selectedProduct.value!;
    final nutrition = product.nutrition;

    if (nutrition == null || nutrition.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Informasi nutrisi belum tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Data nutrisi akan ditambahkan segera',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Nilai Gizi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Per 100 gram',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),

          const SizedBox(height: 16),

          if (nutrition['calories'] != null)
            _buildNutritionItem(
              'Kalori',
              '${nutrition['calories']} kcal',
              Icons.local_fire_department,
              isDark,
            ),
          if (nutrition['protein'] != null)
            _buildNutritionItem(
              'Protein',
              '${nutrition['protein']} g',
              Icons.fitness_center,
              isDark,
            ),
          if (nutrition['fat'] != null)
            _buildNutritionItem(
              'Lemak',
              '${nutrition['fat']} g',
              Icons.opacity,
              isDark,
            ),
          if (nutrition['carbs'] != null)
            _buildNutritionItem(
              'Karbohidrat',
              '${nutrition['carbs']} g',
              Icons.grain,
              isDark,
            ),
          if (nutrition['sugar'] != null)
            _buildNutritionItem(
              'Gula',
              '${nutrition['sugar']} g',
              Icons.water_drop,
              isDark,
            ),
          if (nutrition['fiber'] != null)
            _buildNutritionItem(
              'Serat',
              '${nutrition['fiber']} g',
              Icons.eco,
              isDark,
            ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informasi nutrisi dapat bervariasi tergantung cara pengolahan',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFE8C00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFE8C00), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Product product) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: SafeArea(
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            final deliveryC = Get.find<DeliveryCheckerController>();
            await deliveryC.openWhatsAppWithProduct(product);
          } catch (e) {
            Get.snackbar(
              'Error',
              'Gagal membuka WhatsApp',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Pesan via WhatsApp'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFE8C00),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
  );
}
}