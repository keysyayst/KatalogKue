class Product {
  final String id;
  final String title;
  final String price;
  final String location;
  final String image;
  final String? description;
  final String? composition;
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
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      location: json['location'] ?? '',
      image: json['image_url'] ?? '',
      description: json['description'],
      composition: json['composition'],
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
      'image_url': image,
      'description': description,
      'composition': composition,
    };
  }

  // For insert (tanpa id)
  Map<String, dynamic> toInsertJson() {
    return {
      'title': title,
      'price': price,
      'location': location,
      'image_url': image,
      'description': description,
      'composition': composition,
    };
  }
}