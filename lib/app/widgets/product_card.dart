import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/product.dart';
import '../data/sources/products.dart';
import '../data/services/auth_service.dart';
import '../modules/produk/controllers/produk_controller.dart';
import '../modules/produk/views/detail_produk_page.dart';
import '../modules/favorite/controllers/favorite_controller.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late ProductService productService;

  @override
  void initState() {
    super.initState();
    productService = Get.find<ProductService>();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Get.find<AuthService>();

    return GestureDetector(
      onTap: () {
        try {
          final produkController = Get.find<ProdukController>();
          produkController.selectProduct(widget.product);
          Get.to(() => const DetailProdukPage());
        } catch (e) {
          print('Error navigating to detail: $e');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: _buildProductImage(),
                  ),

                  // ✅ ADMIN BUTTONS - KIRI ATAS
                  if (authService.isAdmin)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigate to edit product
                                Get.snackbar(
                                  'Edit',
                                  'Edit produk: ${widget.product.title}',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                print('Edit product: ${widget.product.id}');
                              },
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                // TODO: Delete product
                                _showDeleteConfirmation();
                              },
                              child: const Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Favorite Button - KANAN ATAS
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () async {
                        await productService.toggleFavorite(widget.product.id);
                        setState(() {});
                        try {
                          Get.find<FavoriteController>().refreshFavorites();
                        } catch (e) {
                          // Skip
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withAlpha(230),
                        radius: 14,
                        child: Icon(
                          productService.isFavorite(widget.product.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: productService.isFavorite(widget.product.id)
                              ? const Color(0xFFFE8C00)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFFFE8C00),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp. ${widget.product.price}',
                    style: const TextStyle(
                      color: Color(0xFFFE8C00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${widget.product.title}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement delete
              Get.snackbar(
                'Terhapus',
                'Produk "${widget.product.title}" telah dihapus',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              print('Delete product: ${widget.product.id}');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    if (widget.product.image.isEmpty) {
      return _buildPlaceholder();
    }

    final isUrl = widget.product.image.startsWith('http');

    if (isUrl) {
      return Image.network(
        widget.product.image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return Image.asset(
        widget.product.image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFE8C00).withOpacity(0.2),
            const Color(0xFFFE8C00).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cake, size: 48, color: Color(0xFFFE8C00)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.product.title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFE8C00),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
