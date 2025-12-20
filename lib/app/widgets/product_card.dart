import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/product.dart';
import '../data/sources/products.dart';
import '../modules/produk/controllers/produk_controller.dart';
import '../modules/produk/views/detail_produk_page.dart';
import '../modules/favorite/controllers/favorite_controller.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final int index;
  const ProductCard({super.key, required this.product, this.index = 0});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  late ProductService productService;

  late AnimationController _entryController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  final Color primaryOrange = const Color(0xFFE67E22);
  final Color textDarkBlue = const Color(0xFF2C3E50);
  final Color textGrey = const Color(0xFF95A5A6);

  @override
  void initState() {
    super.initState();
    productService = Get.find<ProductService>();

    // OPTIMASI 1: Durasi dipercepat (600ms -> 400ms) agar lebih snappy
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // OPTIMASI 2: Delay dipersingkat (100ms -> 30ms) dan dicap max 300ms
    // Agar saat scroll cepat di bawah, item tidak menunggu terlalu lama
    int delay = (widget.index * 30);
    if (delay > 300) delay = 300;

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _entryController.forward();
    });

    // Animasi Tekan (Micro-interaction)
    _pressController = AnimationController(
      duration: const Duration(
        milliseconds: 100,
      ), // Lebih responsif (150 -> 100)
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // OPTIMASI 3: RepaintBoundary
    // Ini mencegah kartu digambar ulang terus-menerus saat parent (Grid) discroll.
    // Sangat penting untuk mengatasi FPS drop.
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _entryController,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _entryController,
                  curve: Curves.easeOutQuad,
                ),
              ),

          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTapDown: (_) => _pressController.forward(),
              onTapUp: (_) => _pressController.reverse(),
              onTapCancel: () => _pressController.reverse(),
              onTap: () async {
                await _pressController.reverse();
                await Future.delayed(
                  const Duration(milliseconds: 80),
                ); // Delay dikit biar smooth

                try {
                  final produkController = Get.find<ProdukController>();
                  produkController.selectProduct(widget.product);
                  Get.to(() => const DetailProdukPage());
                } catch (e) {
                  // ignore
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 3, // Blur dikurangi (4->3) untuk performa
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Hero(
                              tag: 'product_image_${widget.product.id}',
                              // OPTIMASI 4: Gunakan child yang konstan di dalam Hero jika memungkinkan
                              // tapi karena image dinamis, pastikan image cache bekerja (default Flutter)
                              child: _buildProductImage(),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  final favoriteController = Get.find<FavoriteController>();
                                  await favoriteController.toggleFavorite(widget.product.id);
                                  setState(() {});
                                } catch (e) {
                                  debugPrint('Error toggle favorite: $e');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 2, // Optimized shadow
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  productService.isFavorite(widget.product.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color:
                                      productService.isFavorite(
                                        widget.product.id,
                                      )
                                      ? const Color(0xFFE91E63)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : textDarkBlue,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: textGrey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.product.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    color: isDark ? Colors.white70 : textGrey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp. ${widget.product.price}',
                            style: TextStyle(
                              color: primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        // Memori Cache Optimasi untuk Image Network
        cacheWidth: 300, // Membatasi ukuran cache memori agar tidak berat
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return Image.asset(
        widget.product.image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFFFE5D9)),
      child: Center(
        child: Icon(
          Icons.cake,
          size: 32,
          color: primaryOrange.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
