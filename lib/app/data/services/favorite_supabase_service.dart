import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class FavoriteSupabaseService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String table = 'user_favorites';

  Future<void> addFavorite(String userId, String productId) async {
    await _supabase.from(table).upsert({
      'user_id': userId,
      'product_id': productId,
      'favorited_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(String userId, String productId) async {
    await _supabase
        .from(table)
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  Future<List<String>> getFavoriteIds(String userId) async {
    final response = await _supabase
        .from(table)
        .select('product_id')
        .eq('user_id', userId);

    final data = List<Map<String, dynamic>>.from(response);

    return data.map((e) => e['product_id'] as String).toList();
  }

  Future<bool> isFavorite(String userId, String productId) async {
    final response = await _supabase
        .from(table)
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    return response != null;
  }
}
