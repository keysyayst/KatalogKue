import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/produk_controller.dart';
import '../../../data/models/product.dart';
import '../../delivery_checker/controllers/delivery_checker_controller.dart';

class DetailProdukPage extends GetView<ProdukController> {
  const DetailProdukPage({super.key});

  final Color primaryOrange = const Color(0xFFE67E22);
  final Color textDarkBlue = const Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final product = controller.selectedProduct.value!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeroImage(product),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    child: TabBar(
                      onTap: controller.changeTab,
                      indicatorColor: primaryOrange,
                      indicatorWeight: 3,
                      labelColor: primaryOrange,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Deskripsi'),
                        Tab(text: 'Komposisi'),
                        Tab(text: 'Nutrisi'),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildDescriptionTab(product, isDark),
              _buildCompositionTab(product, isDark),
              _buildNutritionTab(isDark),
            ],
          ),
        ),
        bottomNavigationBar: _buildStickyCTA(product, isDark),
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  Widget _buildHeroImage(Product product) {
    if (product.image.isEmpty) {
      return Container(color: Colors.grey[300]);
    }

    final isUrl = product.image.startsWith('http');
    return Stack(
      fit: StackFit.expand,
      children: [
        // HERO WIDGET: Pasangan dari ProductCard agar animasi nyambung
        Hero(
          tag: 'product_image_${product.id}',
          child: isUrl
              ? Image.network(product.image, fit: BoxFit.cover)
              : Image.asset(product.image, fit: BoxFit.cover),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black26, Colors.transparent],
              stops: [0.0, 0.4],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyCTA(Product product, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Harga',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Rp. ${product.price}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final deliveryC = Get.find<DeliveryCheckerController>();
                    await deliveryC.openWhatsAppWithProduct(product);
                  } catch (e) {
                    Get.snackbar('Error', 'Gagal membuka WhatsApp');
                  }
                },
                // Menggunakan Icons.chat karena Icons.whatsapp butuh package external
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('Pesan Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab(Product product, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : textDarkBlue,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.location_on, color: primaryOrange, size: 18),
              const SizedBox(width: 4),
              Text(
                product.location,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            'Tentang Produk',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : textDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description ?? 'Belum ada deskripsi untuk produk ini.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionTab(Product product, bool isDark) {
    final List<String> ingredients = product.compositionList;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bahan Utama',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : textDarkBlue,
            ),
          ),
          const SizedBox(height: 16),
          if (ingredients.isNotEmpty)
            ...ingredients.map(
              (ing) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: primaryOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ing,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildEmptyState('Data komposisi belum tersedia'),
        ],
      ),
    );
  }

  Widget _buildNutritionTab(bool isDark) {
    final product = controller.selectedProduct.value!;
    final nutrition = product.nutrition;

    if (nutrition == null || nutrition.isEmpty) {
      return _buildEmptyState('Informasi nutrisi belum tersedia');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Nilai Gizi',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : textDarkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Per 100 gram penyajian',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          _buildNutriItem(
            'Kalori',
            '${nutrition['calories']} kcal',
            Icons.local_fire_department,
            isDark,
          ),
          _buildNutriItem(
            'Protein',
            '${nutrition['protein']} g',
            Icons.fitness_center,
            isDark,
          ),
          _buildNutriItem(
            'Lemak',
            '${nutrition['fat']} g',
            Icons.opacity,
            isDark,
          ),
          _buildNutriItem(
            'Karbohidrat',
            '${nutrition['carbs']} g',
            Icons.grain,
            isDark,
          ),
          _buildNutriItem(
            'Gula',
            '${nutrition['sugar']} g',
            Icons.water_drop,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNutriItem(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryOrange, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : textDarkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
