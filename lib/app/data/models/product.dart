class Product {
  final String id;
  final String title;
  final String price;
  final String location;
  final String image;
  final String? description;
  final String? composition;
  final Map<String, dynamic>? nutrition;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.image,
    this.description,
    this.composition,
    this.nutrition,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      location: json['location'] ?? '',
      image: json['product_url'] ?? '',
      description: json['description'],
      composition: json['composition'],
      nutrition: json['nutrition'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'location': location,
      'product_url': image,
      'description': description,
      'composition': composition,
      'nutrition': nutrition,
    };
  }

  // For insert (tanpa id)
  Map<String, dynamic> toInsertJson() {
    return {
      'title': title,
      'price': price,
      'location': location,
      'product_url': image,
      'description': description,
      'composition': composition,
      'nutrition': nutrition,
    };
  }

  // Helper untuk parse composition string ke list
  List<String> get compositionList {
    if (composition == null || composition!.isEmpty) return [];
    return composition!
        .split('\n')
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
}
