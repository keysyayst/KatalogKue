import 'package:get/get.dart';
import '../providers/nutrition_api_provider.dart';
import '../models/nutrition_model.dart';

class NutritionService extends GetxService {
  final NutritionApiProvider _provider = NutritionApiProvider();
  
  // Cache untuk menghindari API call berulang
  final Map<String, NutritionData> _cache = {};

  Future<NutritionData?> getNutritionData(String productName) async {
    // Cek cache dulu
    if (_cache.containsKey(productName)) {
      print('📦 Using cached data for: $productName');
      return _cache[productName];
    }

    // Mapping nama produk lokal ke keyword bahasa Inggris
    final searchTerm = _mapProductName(productName);
    
    // Fetch dari API
    final data = await _provider.searchNutrition(searchTerm);
    
    // Simpan ke cache
    if (data != null) {
      _cache[productName] = data;
    }
    
    return data;
  }

  String _mapProductName(String localName) {
    // Mapping produk Indonesia ke bahasa Inggris untuk API
    final Map<String, String> mapping = {
      'Nastar': 'pineapple cookies',
      'Kastengel': 'cheese cookies',
      'Putri Salju': 'sugar cookies',
      'Lidah Kucing': 'butter cookies',
      'Sagu Keju': 'sago cheese cookies',
      'Palm Cheese': 'palmier cookies',
      'Thumbprint': 'thumbprint cookies',
      'Brownies Cup': 'chocolate brownies',
    };
    
    return mapping[localName] ?? 'cookies';
  }

  // Clear cache jika perlu
  void clearCache() {
    _cache.clear();
  }
}