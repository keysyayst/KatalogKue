import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductApiProvider {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error fetching products: $e');
      rethrow;
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Product.fromJson(response);
    } catch (e) {
      print('❌ Error fetching product: $e');
      rethrow;
    }
  }

  // Create product
  Future<Product> createProduct(Product product, String userId) async {
    try {
      final data = product.toInsertJson();
      data['created_by'] = userId;

      final response = await _supabase
          .from('products')
          .insert(data)
          .select()
          .single();

      print('✅ Product created: ${response['id']}');
      return Product.fromJson(response);
    } catch (e) {
      print('❌ Error creating product: $e');
      rethrow;
    }
  }

  // Update product
  Future<Product> updateProduct(String id, Product product) async {
    try {
      final data = product.toInsertJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('products')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      print('✅ Product updated: $id');
      return Product.fromJson(response);
    } catch (e) {
      print('❌ Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);

      print('✅ Product deleted: $id');
    } catch (e) {
      print('❌ Error deleting product: $e');
      rethrow;
    }
  }

  // Upload product image
  Future<String?> uploadProductImage(
    String productId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final path = 'products/$productId/$fileName';

      await _supabase.storage
          .from('product-images')
          .uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final imageUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(path);

      print('✅ Image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }
}
