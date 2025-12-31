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
  final Map<String, dynamic>? operationalHours;
  final double deliveryRadius;
  final double freeDeliveryRadius;
  final int deliveryCostPerKm;
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
    this.operationalHours,
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
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(json['longitude'] ?? json['lng']),
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      operationalHours: json['operationalhours'] is Map<String, dynamic>
          ? json['operationalhours'] as Map<String, dynamic>
          : json['operationalhours'] != null
          ? Map<String, dynamic>.from(json['operationalhours'])
          : null,
      deliveryRadius: _toDouble(
        json['delivery_radius'] ?? json['deliveryradius'],
      ),
      freeDeliveryRadius: _toDouble(
        json['free_delivery_radius'] ?? json['freedeliveryradius'],
      ),
      deliveryCostPerKm: _toInt(
        json['delivery_cost_per_km'] ?? json['deliverycostperkm'],
      ),
      minOrder: _toInt(json['min_order'] ?? json['minorder']),
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
    Map<String, dynamic>? operationalHours,
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
      operationalHours: operationalHours ?? this.operationalHours,
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
