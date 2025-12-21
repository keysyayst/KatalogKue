import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/produk_controller.dart';
import '../../../widgets/product_card.dart';

class ProdukPage extends GetView<ProdukController> {
  const ProdukPage({super.key});

  final Color primaryOrange = const Color(0xFFE67E22);
  final Color darkBlueGrey = const Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: controller.refreshProducts,
        color: primaryOrange,
        child: CustomScrollView(
          // OPTIMASI 2: Keyboard otomatis turun saat scroll
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          cacheExtent: 1000, // Preload item lebih banyak agar scroll smooth
          slivers: [
            _buildSliverAppBar(context, isDark),

            // Search Bar (Static, tidak perlu rebuild terus menerus)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: _buildSearchBar(isDark),
              ),
            ),

            // Bagian Reactive (History, Count, Grid, Loading)
            // OPTIMASI 1: Obx dipecah ke dalam sliver agar lebih granular
            Obx(() {
              // Loading State
              if (controller.productService.isLoading.value) {
                return _buildShimmerSliver(isDark);
              }

              return SliverMainAxisGroup(
                slivers: [
                  // History Section
                  if (controller.searchHistory.isNotEmpty &&
                      controller.searchQuery.value.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildSearchHistorySection(isDark),
                    ),

                  // Product Count
                  if (controller.filteredProducts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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
                      hasScrollBody: false,
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
                    // Product Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = controller.filteredProducts[index];
                          // Tambahkan UniqueKey jika perlu untuk performa list dinamis
                          return ProductCard(
                            key: ValueKey(product.id),
                            product: product,
                            index: index,
                          );
                        }, childCount: controller.filteredProducts.length),
                      ),
                    ),

                  // Bottom Padding
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terakhir Dicari',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : darkBlueGrey,
                ),
              ),
              GestureDetector(
                onTap: controller.clearSearchHistory,
                child: Text(
                  'Hapus Semua',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: controller.searchHistory.map((history) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InputChip(
                  label: Text(
                    history,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: isDark ? Colors.white : darkBlueGrey,
                    ),
                  ),
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  onPressed: () => controller.applySearchFromHistory(history),
                  onDeleted: () => controller.removeSearchHistory(history),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.all(0),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

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
        focusNode: controller.searchFocusNode,
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

  // Mengubah return type menjadi Widget agar bisa masuk SliverMainAxisGroup tapi perlu dibungkus
  // Karena SliverMainAxisGroup mengharapkan Slivers, kita kembalikan SliverPadding langsung.
  Widget _buildShimmerSliver(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
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
        }, childCount: 6),
      ),
    );
  }
}
