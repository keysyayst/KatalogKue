import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import 'dart:io';

class ProductSupabaseService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RxList<Product> products = <Product>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      products.value = (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('products').insert({
        ...product.toInsertJson(),
        'created_by': userId,
      });
      await loadProducts();
      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      Get.snackbar('Error', 'Gagal menambah produk: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct(String id, Product product) async {
    try {
      isLoading.value = true;
      await _supabase
          .from('products')
          .update({
            ...product.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      await loadProducts();
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      Get.snackbar('Error', 'Gagal memperbarui produk: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      isLoading.value = true;

      // Hapus semua favorit produk ini terlebih dahulu
      await _supabase.from('user_favorites').delete().eq('product_id', id);

      // Kemudian hapus produk
      await _supabase.from('products').delete().eq('id', id);
      await loadProducts();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      Get.snackbar('Error', 'Gagal menghapus produk: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> uploadImage(File imageFile, String productId) async {
    try {
      final fileName =
          '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'products/$fileName';
      await _supabase.storage.from('product-images').upload(path, imageFile);
      final imageUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      Get.snackbar('Error', 'Gagal upload gambar: ${e.toString()}');
      return null;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.last;
      await _supabase.storage.from('product-images').remove(['products/$path']);
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  Product? getProductById(String id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
