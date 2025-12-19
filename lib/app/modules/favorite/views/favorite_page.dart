import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/product_card.dart';
import '../controllers/favorite_controller.dart';
// Import DashboardController agar bisa ganti tab
import '../../../app.dart';

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final favs = controller.favoriteProducts;

        // ==========================================
        // EMPTY STATE (Belum ada favorit)
        // ==========================================
        if (favs.isEmpty) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Icon
                        _AnimatedEmptyStateIcon(),
                        const SizedBox(height: 32),

                        // Text & Button
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Fade in text
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: const Text(
                                'Belum ada produk favorit',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                  height: 1.4,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Animated Button
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: IntrinsicWidth(
                                child: _AnimatedCTAButton(
                                  // PERBAIKAN NAVIGASI DI SINI
                                  onPressed: () {
                                    try {
                                      // Cari DashboardController dan pindah ke Tab 1 (Produk)
                                      final dashboard =
                                          Get.find<DashboardController>();
                                      dashboard.changeTabIndex(1);
                                    } catch (e) {
                                      print(
                                        "DashboardController not found: $e",
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // ==========================================
        // LIST FAVORIT (Ada Data)
        // ==========================================
        return CustomScrollView(
          slivers: [
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

            // Product Grid dengan staggered animation
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _AnimatedProductCard(
                    index: index,
                    child: ProductCard(product: favs[index]),
                  );
                }, childCount: favs.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      }),
    );
  }

  // SliverAppBar Widget
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFE67E22),
      foregroundColor: Colors.white,
      elevation: 2,
      automaticallyImplyLeading: false,
      // Fix: withOpacity -> withValues
      shadowColor: const Color(0xFF000000).withValues(alpha: 0.05),

      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        centerTitle: false,
        title: const Text(
          'Favorit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        background: _AnimatedAppBarBackground(),
      ),
    );
  }
}

// ========================================
// ANIMATED WIDGETS
// ========================================

// 1. Animated Empty State Icon
class _AnimatedEmptyStateIcon extends StatefulWidget {
  @override
  State<_AnimatedEmptyStateIcon> createState() =>
      _AnimatedEmptyStateIconState();
}

class _AnimatedEmptyStateIconState extends State<_AnimatedEmptyStateIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE5D9),
              boxShadow: [
                BoxShadow(
                  // Fix: withOpacity -> withValues
                  color: const Color(
                    0xFFE67E22,
                  ).withValues(alpha: 0.15 * _opacityAnimation.value),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: Color(0xFFE67E22),
            ),
          ),
        );
      },
    );
  }
}

// 2. Animated CTA Button
class _AnimatedCTAButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedCTAButton({required this.onPressed});

  @override
  State<_AnimatedCTAButton> createState() => _AnimatedCTAButtonState();
}

class _AnimatedCTAButtonState extends State<_AnimatedCTAButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFE67E22),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    // Fix: withOpacity -> withValues
                    color: const Color(0xFFE67E22).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: const Center(
          child: Text(
            'Jelajahi Produk',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// 3. Animated Product Card
class _AnimatedProductCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedProductCard({required this.index, required this.child});

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _shadowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _shadowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shadowController, curve: Curves.easeOutCubic),
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);

    if (isHovered) {
      _scaleController.forward();
      _shadowController.forward();
      _shimmerController.repeat();
    } else {
      _scaleController.reverse();
      _shadowController.reverse();
      _shimmerController.stop();
      _shimmerController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Transform.scale(scale: 0.8 + (0.2 * value), child: child),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => _onHover(true),
          onTapUp: (_) {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) _onHover(false);
            });
          },
          onTapCancel: () => _onHover(false),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              _shadowAnimation,
              _shimmerController,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Stack(
                  children: [
                    // Card Wrapper
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // Fix: withOpacity -> withValues
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            // Fix: withOpacity -> withValues
                            color: const Color(
                              0xFFE67E22,
                            ).withValues(alpha: 0.2 * _shadowAnimation.value),
                            blurRadius: 20 * _shadowAnimation.value,
                            offset: Offset(0, 8 * _shadowAnimation.value),
                            spreadRadius: 2 * _shadowAnimation.value,
                          ),
                        ],
                      ),
                      child: child,
                    ),

                    // Shimmer Overlay
                    if (_isHovered)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(
                                      -1.0 + 3 * _shimmerController.value,
                                      -0.5,
                                    ),
                                    end: Alignment(
                                      3 * _shimmerController.value,
                                      0.5,
                                    ),
                                    colors: [
                                      Colors.transparent,
                                      // Fix: withOpacity -> withValues
                                      Colors.white.withValues(alpha: 0.15),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Border Highlight
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              // Fix: withOpacity -> withValues
                              color: const Color(
                                0xFFE67E22,
                              ).withValues(alpha: 0.3 * _shadowAnimation.value),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// 4. Animated AppBar Background
class _AnimatedAppBarBackground extends StatefulWidget {
  @override
  State<_AnimatedAppBarBackground> createState() =>
      _AnimatedAppBarBackgroundState();
}

class _AnimatedAppBarBackgroundState extends State<_AnimatedAppBarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE67E22), Color(0xFFD35400)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40 + (20 * _controller.value),
                top: -40 - (10 * _controller.value),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Fix: withOpacity -> withValues
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 40 - (15 * _controller.value),
                top: 20 + (10 * _controller.value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Fix: withOpacity -> withValues
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                left: -20 + (10 * _controller.value),
                bottom: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Fix: withOpacity -> withValues
                    color: const Color(0xFFD35400).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
