import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fitness_app/full body/exercise_model.dart';
import 'package:fitness_app/full body/exercise_player_screen.dart';

class ExerciseListScreen extends StatelessWidget {
  final String title;
  final List<ExerciseModel> exercises;
  final String bannerImage;

  const ExerciseListScreen({
    super.key,
    required this.exercises,
    required this.title,
    required this.bannerImage,
  });

  @override
  Widget build(BuildContext context) {
    final totalDuration = _calculateTotalDuration(exercises);
    final totalExercises = exercises.length.toString();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 180,
                leading: const BackButton(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    bannerImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _grayInfoCard(totalDuration, "Duration"),
                          _grayInfoCard(totalExercises, "Exercises"),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Exercises",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = exercises[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListTile(
                            leading: exercise.isAnimation
                                ? Lottie.asset(
                                    exercise.filePath,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    exercise.filePath,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                            title: Text(
                              exercise.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              exercise.time,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 1,
                          color: Colors.grey,
                          indent: 16,
                          endIndent: 16,
                        ),
                      ],
                    );
                  },
                  childCount: exercises.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Start Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExercisePlayerScreen(
                      exercises: exercises,
                      startIndex: 0,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Start",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalDuration(List<ExerciseModel> exercises) {
    final totalSeconds = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.durationInSeconds,
    );
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _grayInfoCard(String value, String label) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
