class NutritionData {
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double sugar;
  final double fiber;

  NutritionData({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.sugar = 0.0,
    this.fiber = 0.0,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    final nutrients = json['foodNutrients'] as List? ?? [];

    double getValueByName(String nutrientName) {
      try {
        final nutrient = nutrients.firstWhere(
          (n) => n['nutrientName'].toString().toLowerCase().contains(
            nutrientName.toLowerCase(),
          ),
          orElse: () => {'value': 0.0},
        );
        return (nutrient['value'] ?? 0.0).toDouble();
      } catch (e) {
        return 0.0;
      }
    }

    return NutritionData(
      name: json['description'] ?? 'Unknown',
      calories: getValueByName('Energy'),
      protein: getValueByName('Protein'),
      fat: getValueByName('Total lipid'),
      carbs: getValueByName('Carbohydrate'),
      sugar: getValueByName('Sugars, total'),
      fiber: getValueByName('Fiber'),
    );
  }

  // Dummy data untuk fallback
  factory NutritionData.dummy() {
    return NutritionData(
      name: 'Cookies',
      calories: 502.0,
      protein: 5.9,
      fat: 24.4,
      carbs: 66.5,
      sugar: 32.1,
      fiber: 2.3,
    );
  }
}
