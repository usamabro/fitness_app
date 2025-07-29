import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ExerciseListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, String>> exercises;

  const ExerciseListScreen({
    required this.title,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFFB31919),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Lottie.asset(
                      exercise['animation']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  exercise['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  exercise['duration']!,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFFB31919),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
