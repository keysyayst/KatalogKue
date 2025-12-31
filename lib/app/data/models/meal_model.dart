class Meal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final List<String> ingredients;
  final List<String> measurements;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.ingredients = const [],
    this.measurements = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measurements = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measurements.add(measure?.toString().trim() ?? '');
      }
    }

    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? 'Unknown',
      strMealThumb: json['strMealThumb'] ?? '',
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      ingredients: ingredients,
      measurements: measurements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
    };
  }

  String get compositionText {
    if (ingredients.isEmpty) return '';

    List<String> composed = [];
    for (int i = 0; i < ingredients.length; i++) {
      if (measurements[i].isNotEmpty) {
        composed.add('${measurements[i]} ${ingredients[i]}');
      } else {
        composed.add(ingredients[i]);
      }
    }
    return composed.join('\n');
  }
}
