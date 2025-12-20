// lib/app/modules/produk/views/produk_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/produk_controller.dart';
import '../../../widgets/product_card.dart';

class ProdukPage extends GetView<ProdukController> {
  const ProdukPage({super.key});

  // Brand Colors
  final Color primaryOrange = const Color(0xFFE67E22);
  final Color darkBlueGrey = const Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      body: Obx(() {
        // ANIMASI 1: SHIMMER LOADING (Pengganti Spinner)
        if (controller.productService.isLoading.value) {
          return _buildShimmerLoading(isDark);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProducts,
          color: primaryOrange,
          child: CustomScrollView(
            // OPTIMASI: Pre-render 500 pixel ke bawah agar scroll ngebut tidak patah-patah (Lag-free)
            cacheExtent: 500,
            slivers: [
              // ========================================
              // APP BAR & SEARCH
              // ========================================
              _buildSliverAppBar(context, isDark),

              // Search Bar (Pinned dibawah AppBar atau scroll away)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: _buildSearchBar(isDark),
                ),
              ),

              // ========================================
              // PRODUCT GRID
              // ========================================

              // Product Count Header
              if (controller.filteredProducts.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8,
                    ),
                    child: Text(
                      '${controller.filteredProducts.length} Produk Tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // Empty State
              if (controller.filteredProducts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isEmpty
                              ? 'Belum ada produk'
                              : 'Produk tidak ditemukan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Mobile 2 columns
                          childAspectRatio: 0.72, // Ratio kartu
                          crossAxisSpacing: 12, // Gap horizontal
                          mainAxisSpacing: 12, // Gap vertikal
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = controller.filteredProducts[index];
                      // Pass 'index' untuk animasi staggered (muncul berurutan)
                      return ProductCard(product: product, index: index);
                    }, childCount: controller.filteredProducts.length),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ), // Bottom padding
            ],
          ),
        );
      }),
    );
  }

  // ========================================
  // WIDGET METHODS
  // ========================================

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      elevation: 2,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Katalog Kue',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryOrange, const Color(0xFFFF9F43)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => controller.refreshProducts(),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        focusNode: controller.searchFocusNode, // ✅ TAMBAHAN INI
        onChanged: controller.searchProducts,
        onSubmitted: (query) {
          controller.saveSearchToHistory(query);
        },
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: isDark ? Colors.white : darkBlueGrey,
        ),
        decoration: InputDecoration(
          hintText: 'Cari kue favorit...',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFE67E22)),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: controller.clearSearch,
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE67E22), width: 1.5),
          ),
        ),
      ),
    );
  }

  // WIDGET SKELETON (SHIMMER MANUAL)
  Widget _buildShimmerLoading(bool isDark) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(Get.context!, isDark),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: _buildSearchBar(isDark),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 14,
                              color: isDark ? Colors.grey[700] : Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 12,
                              color: isDark ? Colors.grey[700] : Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: 6, // Tampilkan 6 skeleton dummy
            ),
          ),
        ),
      ],
    );
  }
}
