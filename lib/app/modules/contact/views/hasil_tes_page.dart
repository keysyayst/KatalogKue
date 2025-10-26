import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/meal_model.dart'; // Import model yang baru kita buat

class HasilTesPage extends StatelessWidget {
  const HasilTesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil semua data yang kita kirim dari controller
    final Map<String, dynamic> arguments = Get.arguments;
    final String libraryName = arguments['library'];
    final int duration = arguments['duration'];
    final List<Meal> meals = arguments['meals'];

    return Scaffold(
      appBar: AppBar(
        // Tampilkan library apa dan berapa waktunya di AppBar
        title: Text('$libraryName: $duration ms'),
        backgroundColor: libraryName == 'HTTP' ? Colors.lightGreen : Colors.orange,
      ),
      body: ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          // Tampilkan data resep dalam bentuk list
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(meal.thumbnail),
            ),
            title: Text(meal.name),
            subtitle: Text('ID Resep: ${meal.id}'),
          );
        },
      ),
    );
  }
}