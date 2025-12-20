class Store {
  final String id;
  final String name;
  final String owner;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String whatsapp;
  final String email;
  final Map<String, dynamic> operationalHours;
  final double deliveryRadius;
  final double freeDeliveryRadius;
  final int deliveryCostPerKm;
  final int minOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    required this.owner,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.operationalHours,
    required this.deliveryRadius,
    required this.freeDeliveryRadius,
    required this.deliveryCostPerKm,
    required this.minOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      owner: json['owner'] as String,
      address: json['address'] as String,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      phone: json['phone'] as String,
      whatsapp: json['whatsapp'] as String,
      email: json['email'] as String,
      operationalHours: Map<String, dynamic>.from(
        json['operationalhours'] ?? {},
      ),
      deliveryRadius: (json['deliveryradius'] as num).toDouble(),
      freeDeliveryRadius: (json['freedeliveryradius'] as num).toDouble(),
      deliveryCostPerKm: json['deliverycostperkm'] as int,
      minOrder: json['minorder'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'address': address,
      'lat': latitude,
      'lng': longitude,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'operationalhours': operationalHours,
      'deliveryradius': deliveryRadius,
      'freedeliveryradius': freeDeliveryRadius,
      'deliverycostperkm': deliveryCostPerKm,
      'minorder': minOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
