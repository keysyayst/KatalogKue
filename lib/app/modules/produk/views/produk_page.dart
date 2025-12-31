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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          cacheExtent: 1000,
          slivers: [
            _buildSliverAppBar(context, isDark),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildSearchBar(isDark),
              ),
            ),

            // === BARIS FILTER: SORT | HARGA | KALORI ===
            SliverToBoxAdapter(child: _buildSortFilterBar(context, isDark)),

            // ===========================================
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

  // --- WIDGET BARU: SORT & FILTER UI (SEJAJAR) ---
  Widget _buildSortFilterBar(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // 1. TOMBOL SORT
          Obx(
            () => PopupMenuButton<String>(
              onSelected: (val) {
                controller.changeSort(val);
                controller.isSortMenuOpen.value = false;
              },
              onCanceled: () => controller.isSortMenuOpen.value = false,
              onOpened: () => controller.isSortMenuOpen.value = true,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'default', child: Text('Default')),
                const PopupMenuItem(
                  value: 'price_low',
                  child: Text('Harga Terendah'),
                ),
                const PopupMenuItem(
                  value: 'price_high',
                  child: Text('Harga Tertinggi'),
                ),
                const PopupMenuItem(value: 'a_z', child: Text('Nama (A-Z)')),
                const PopupMenuItem(value: 'z_a', child: Text('Nama (Z-A)')),
              ],
              offset: const Offset(0, 48),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.selectedSort.value == 'default'
                        ? Colors.grey.withOpacity(0.3)
                        : primaryOrange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort,
                      size: 18,
                      color: controller.selectedSort.value == 'default'
                          ? (isDark ? Colors.white : Colors.black)
                          : primaryOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getSortLabel(controller.selectedSort.value),
                      style: TextStyle(
                        color: controller.selectedSort.value == 'default'
                            ? (isDark ? Colors.white : Colors.black)
                            : primaryOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Obx(
                      () => Icon(
                        controller.isSortMenuOpen.value
                            ? Icons.keyboard_arrow_down
                            : Icons.chevron_right,
                        size: 18,
                        color: controller.selectedSort.value == 'default'
                            ? (isDark ? Colors.white54 : Colors.black45)
                            : primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 2. TOMBOL FILTER HARGA
          GestureDetector(
            onTap: () {
              _showFilterBottomSheet(context, isDark);
            },
            child: Obx(() {
              // Cek filter aktif
              bool isFilterActive =
                  controller.maxPriceFilter.value < 1000000.0 ||
                  controller.minPriceFilter.value > 0.0;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isFilterActive
                        ? primaryOrange
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 18,
                      color: isFilterActive
                          ? primaryOrange
                          : (isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Filter Harga",
                      style: TextStyle(
                        color: isFilterActive
                            ? primaryOrange
                            : (isDark ? Colors.white : Colors.black),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(width: 10),

          // 3. FILTER KALORI (CHIP) - DISEBELAH HARGA
          Obx(() {
            final isSelected = controller.isLowCalorie.value;
            return FilterChip(
              // Ikon api hijau
              avatar: isSelected
                  ? null
                  : const Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.green,
                    ),
              label: Text(
                "Kalori < 300",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : darkBlueGrey),
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                controller.toggleLowCalorie(selected);
              },
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              selectedColor: Colors.green, // Warna Hijau saat aktif
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.green
                      : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            );
          }),
        ],
      ),
    );
  }

  String _getSortLabel(String value) {
    switch (value) {
      case 'price_low':
        return 'Harga Terendah';
      case 'price_high':
        return 'Harga Tertinggi';
      case 'a_z':
        return 'Nama (A-Z)';
      case 'z_a':
        return 'Nama (Z-A)';
      default:
        return 'Urutkan';
    }
  }

  void _showFilterBottomSheet(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter Harga",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(
                () => Column(
                  children: [
                    RangeSlider(
                      values: RangeValues(
                        controller.minPriceFilter.value.clamp(0, 1000000),
                        controller.maxPriceFilter.value.clamp(0, 1000000),
                      ),
                      min: 0,
                      max: 1000000,
                      divisions: 100,
                      activeColor: primaryOrange,
                      inactiveColor: Colors.grey[300],
                      labels: RangeLabels(
                        "Rp ${_formatCurrency(controller.minPriceFilter.value)}",
                        "Rp ${_formatCurrency(controller.maxPriceFilter.value)}",
                      ),
                      onChanged: (RangeValues values) {
                        controller.changePriceRange(values.start, values.end);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rp ${_formatCurrency(controller.minPriceFilter.value)}",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Rp ${_formatCurrency(controller.maxPriceFilter.value)}",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Terapkan Filter",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    controller.changePriceRange(0, 1000000);
                    Get.back();
                  },
                  child: const Text(
                    "Reset",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
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
