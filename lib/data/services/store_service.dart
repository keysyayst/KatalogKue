import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store.dart';

class StoreService {
  final _client = Supabase.instance.client;

  Future<Store?> fetchActiveStore() async {
    final response = await _client
        .from('delivery_stores')
        .select()
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();
    if (response == null) return null;
    return Store.fromJson(response);
  }

  Future<void> updateStore(Store store) async {
    await _client
        .from('delivery_stores')
        .update(store.toJson())
        .eq('id', store.id);
  }
}
