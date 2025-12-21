import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/meal_model.dart';
import '../../../theme/design_system.dart';

class HasilTesPage extends StatelessWidget {
  const HasilTesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final String library = args['library'] ?? 'Unknown';
    final int duration = args['duration'] ?? 0;
    final List<Meal> meals = args['meals'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Tes $library', style: const TextStyle(fontFamily: DesignText.family)),
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Performance Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignColors.primary,
                  DesignColors.primary.withOpacity(0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DesignColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  library,
                  style: const TextStyle(
                    fontFamily: DesignText.family,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      icon: Icons.timer,
                      label: 'Durasi',
                      value: '$duration ms',
                    ),
                    _buildInfoItem(
                      icon: Icons.data_usage,
                      label: 'Data',
                      value: '${meals.length} items',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: DesignColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Daftar Dessert (${meals.length})',
                      style: const TextStyle(
                        fontFamily: DesignText.family,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
          ),
          
          // Meal List
          Expanded(
            child: meals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada data',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: meals.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              meal.strMealThumb,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.cake,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            meal.strMeal,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${meal.idMeal}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: DesignColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
