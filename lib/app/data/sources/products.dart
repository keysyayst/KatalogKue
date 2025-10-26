import 'package:get/get.dart';
import '../models/product.dart'; 

final List<Map<String, dynamic>> allProductsData = [
  {
    'id': 'n1',
    'title': 'Nastar Classic',
    'location': 'Malang',
    'price': 70000,
    'image': 'assets/images/nastar.png',
  },
  {
    'id': 'k1',
    'title': 'Kastengel',
    'location': 'Malang',
    'price': 65000,
    'image': 'assets/images/kastengel.png',
  },
  {
    'id': 'l1',
    'title': 'Lidah Kucing',
    'location': 'Malang',
    'price': 50000,
    'image': 'assets/images/lidahkucing.png',
  },
  {
    'id': 's1',
    'title': 'Sagu Keju',
    'location': 'Malang',
    'price': 45000,
    'image': 'assets/images/sagukeju.png',
  },
  {
    'id': 'p1',
    'title': 'Putri Salju',
    'location': 'Malang',
    'price': 55000,
    'image': 'assets/images/putrisalju.png',
  },
  {
    'id': 'c1',
    'title': 'Brownies Cup',
    'location': 'Malang',
    'price': 60000,
    'image': 'assets/images/browniescup.png',
  },
  {
    'id': 'p2',
    'title': 'Palm Cheese',
    'location': 'Malang',
    'price': 50000,
    'image': 'assets/images/palmcheese.png',
  },
  {
    'id': 'b1',
    'title': 'Thumbrint',
    'location': 'Malang',
    'price': 48000,
    'image': 'assets/images/thumbrin.png',
  },
];

class ProductService extends GetxService {
  final allProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    allProducts.value = allProductsData.map((data) {
      return Product(
        id: data['id'],
        title: data['title'],
        location: data['location'],
        price: data['price'],
        image: data['image'],
        isFavorite: false,
      );
    }).toList();
  }

  List<Product> get favoriteProducts {
    return allProducts.where((product) => product.isFavorite.value).toList();
  }

  Product? getProductById(String id) {
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
