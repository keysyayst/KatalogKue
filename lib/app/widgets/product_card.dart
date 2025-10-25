import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/product.dart'; // <-- Path Relatif
import '../routes/app_pages.dart'; // <-- Path Relatif

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.productDetail.replaceAll(':id', product.id), // <-- Diperbaiki
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // <-- Diperbaiki (0.05 * 255)
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Image.asset(
                      product.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => product.isFavorite.toggle(),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withAlpha(
                          230,
                        ), // <-- Diperbaiki (0.9 * 255)
                        radius: 14,
                        child: Obx(
                          () => Icon(
                            product.isFavorite.value
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: product.isFavorite.value
                                ? const Color(0xFFFE8C00)
                                : Colors.grey,
                          ),
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
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
                        product.location,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp. ${product.price}',
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
}