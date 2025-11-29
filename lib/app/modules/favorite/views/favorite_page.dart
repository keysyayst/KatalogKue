import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/product_card.dart'; 
import '../controllers/favorite_controller.dart'; 

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final favs = controller.favoriteProducts;

        // Empty state
        if (favs.isEmpty) {
          return CustomScrollView(
            slivers: [
              // ========================================
              // SLIVER APP BAR (KE KIRI)
              // ========================================
              _buildSliverAppBar(),

              // Empty State
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFE8C00).withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Belum ada produk favorit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Produk yang Anda sukai akan muncul di sini',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Content with favorites
        return CustomScrollView(
          slivers: [
            // ========================================
            // SLIVER APP BAR (KE KIRI)
            // ========================================
            _buildSliverAppBar(),

            // Favorite Count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '${favs.length} Produk Favorit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Product Grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ProductCard(product: favs[index]);
                  },
                  childCount: favs.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
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
          'Favorit',
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
    );
  }
}
