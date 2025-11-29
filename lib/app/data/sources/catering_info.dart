class CateringInfo {
  static const Map<String, dynamic> store = {
    'name': 'Catering Kue Made by Mommy',
    'owner': 'Ekky Santi',
    'address': 'Gg. Makam No.54, Pandanwangi, Kec. Blimbing, Kota Malang, Jawa Timur 65126',
    'lat': -7.9517177, // ← Ganti dengan koordinat real catering
    'lng': 112.6600066,
    'phone': '085282483177',
    'whatsapp': '6285282483177',
    'email': 'catering@gmail.com',
    'operationalHours': {
      'senin-jumat': '08:00 - 17:00',
      'sabtu': '08:00 - 14:00',
      'minggu': 'Tutup',
    },
    'deliveryRadius': 10.0, // km
    'freeDeliveryRadius': 5.0, // km
    'deliveryCostPerKm': 2000, // Rp/km setelah radius gratis
    'minOrder': 50000, // Minimum pemesanan
  };

  static const List<String> deliveryAreas = [
    'Lowokwaru',
    'Blimbing', 
    'Klojen',
    'Sukun',
    'Kedungkandang',
  ];
}
