// Model data DeliveryStore
class DeliveryStore {
  final String id;
  final String name;
  final String owner;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String whatsapp;
  final String email;
  final double deliveryRadius; 
  final double freeDeliveryRadius; 
  final int
  deliveryCostPerKm; 
  final int minOrder; 
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryStore({
    required this.id,
    required this.name,
    required this.owner,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.deliveryRadius,
    required this.freeDeliveryRadius,
    required this.deliveryCostPerKm,
    required this.minOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryStore.fromJson(Map<String, dynamic> json) {
    return DeliveryStore(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      deliveryRadius: _toDouble(json['delivery_radius']),
      freeDeliveryRadius: _toDouble(json['free_delivery_radius']),
      deliveryCostPerKm: _toInt(json['delivery_cost_per_km']),
      minOrder: _toInt(json['min_order']),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'delivery_radius': deliveryRadius,
      'free_delivery_radius': freeDeliveryRadius,
      'delivery_cost_per_km': deliveryCostPerKm,
      'min_order': minOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeliveryStore copyWith({
    String? id,
    String? name,
    String? owner,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? whatsapp,
    String? email,
    double? deliveryRadius,
    double? freeDeliveryRadius,
    int? deliveryCostPerKm,
    int? minOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryStore(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      freeDeliveryRadius: freeDeliveryRadius ?? this.freeDeliveryRadius,
      deliveryCostPerKm: deliveryCostPerKm ?? this.deliveryCostPerKm,
      minOrder: minOrder ?? this.minOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static DateTime _toDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }
}
