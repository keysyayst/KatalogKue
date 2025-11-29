import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/produk_controller.dart';
import '../../../widgets/product_card.dart';

class ProdukPage extends GetView<ProdukController> {
  const ProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        // Tampilkan loading saat data sedang dimuat
        if (controller.productService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFE8C00),
            ),
          );
        }

        // Empty state
        if (controller.filteredProducts.isEmpty) {
          return CustomScrollView(
            slivers: [
              // ========================================
              // SLIVER APP BAR (KE KIRI)
              // ========================================
              _buildSliverAppBar(),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.searchProducts,
                    onSubmitted: (query) {
                      controller.saveSearchToHistory(query);
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFFE8C00),
                      ),
                      suffixIcon: Obx(
                        () => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clearSearch,
                              )
                            : const SizedBox.shrink(),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              // Empty State
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isEmpty
                            ? 'Belum ada produk'
                            : 'Produk tidak ditemukan',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      if (controller.searchQuery.value.isEmpty) ...[
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => controller.refreshProducts(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFE8C00),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Content with products
        return RefreshIndicator(
          onRefresh: controller.refreshProducts,
          color: const Color(0xFFFE8C00),
          child: CustomScrollView(
            slivers: [
              // ========================================
              // SLIVER APP BAR (KE KIRI)
              // ========================================
              _buildSliverAppBar(),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.searchProducts,
                    onSubmitted: (query) {
                      controller.saveSearchToHistory(query);
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFFE8C00),
                      ),
                      suffixIcon: Obx(
                        () => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clearSearch,
                              )
                            : const SizedBox.shrink(),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              // Search History
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.searchHistory.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Riwayat Pencarian',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () => controller.clearSearchHistory(),
                              child: const Text(
                                'Hapus Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFE8C00),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.searchHistory.map((query) {
                            return InkWell(
                              onTap: () =>
                                  controller.applySearchFromHistory(query),
                              child: Chip(
                                label: Text(query),
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                backgroundColor: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey[200],
                                deleteIcon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                onDeleted: () =>
                                    controller.removeSearchHistory(query),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                avatar: Icon(
                                  Icons.history,
                                  size: 16,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }),
              ),

              // Product Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Obx(
                    () => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${controller.filteredProducts.length} Produk Tersedia',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Product Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = controller.filteredProducts[index];
                      return ProductCard(product: product);
                    },
                    childCount: controller.filteredProducts.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        );
      }),
    );
  }

  // ========================================
  // SLIVER APP BAR (KE KIRI)
  // ========================================

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFFE8C00),
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false, // Hilangkan back button
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16), // ← KE KIRI
        title: const Text(
          'Semua Produk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                const Color(0xFFFE8C00),
                const Color(0xFFFF6B00),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
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
}