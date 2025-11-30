import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/delivery_store_model.dart';

class DeliveryStoreRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _table = 'delivery_stores';

  /// Get all active delivery stores
  Future<List<DeliveryStore>> getAllStores() async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('is_active', true)
          .order('name');

      final stores = (response as List)
          .map((item) => DeliveryStore.fromJson(item as Map<String, dynamic>))
          .toList();

      print('✅ Loaded ${stores.length} delivery stores');
      return stores;
    } catch (e) {
      print('❌ Error fetching stores: $e');
      return [];
    }
  }

  /// Get store by ID
  Future<DeliveryStore?> getStoreById(String storeId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('id', storeId)
          .single();

      return DeliveryStore.fromJson(response);
    } catch (e) {
      print('❌ Error fetching store $storeId: $e');
      return null;
    }
  }

  /// Add new delivery store
  Future<DeliveryStore?> addStore(DeliveryStore store) async {
    try {
      print('📤 Sending store data: ${store.toJson()}');

      final response = await _supabase
          .from(_table)
          .insert(store.toJson())
          .select()
          .single();

      print('✅ Store created successfully: ${store.name}');
      print('📥 Response: $response');
      return DeliveryStore.fromJson(response);
    } catch (e) {
      print('❌ Error adding store: $e');
      print('📋 Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Update delivery store
  Future<DeliveryStore?> updateStore(
    String storeId,
    DeliveryStore store,
  ) async {
    try {
      final response = await _supabase
          .from(_table)
          .update(store.copyWith(updatedAt: DateTime.now()).toJson())
          .eq('id', storeId)
          .select()
          .single();

      print('✅ Store updated: ${store.name}');
      return DeliveryStore.fromJson(response);
    } catch (e) {
      print('❌ Error updating store: $e');
      return null;
    }
  }

  /// Delete delivery store
  Future<bool> deleteStore(String storeId) async {
    try {
      await _supabase.from(_table).delete().eq('id', storeId);
      print('✅ Store deleted: $storeId');
      return true;
    } catch (e) {
      print('❌ Error deleting store: $e');
      return false;
    }
  }

  /// Toggle store active status
  Future<bool> toggleStoreActive(String storeId, bool isActive) async {
    try {
      await _supabase
          .from(_table)
          .update({'is_active': isActive})
          .eq('id', storeId);

      print('✅ Store status updated: $storeId -> $isActive');
      return true;
    } catch (e) {
      print('❌ Error toggling store status: $e');
      return false;
    }
  }
}
