class Meal {
  final String id;
  final String name;
  final String thumbnail; // URL gambar

  Meal({required this.id, required this.name, required this.thumbnail});

  // Factory constructor untuk mengubah JSON dari API menjadi objek Meal
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'],
      name: json['strMeal'],
      thumbnail: json['strMealThumb'],
    );
  }
}
