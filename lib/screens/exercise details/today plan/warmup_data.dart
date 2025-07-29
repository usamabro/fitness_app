import 'package:fitness_app/full body/exercise_model.dart';

final List<ExerciseModel> warmupExercises = [
  ExerciseModel(
    name: "Jumping Jacks",
    filePath: "assets/lottie/jumping_jacks.json",
    time: "00:30",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "Arm Circles",
    filePath: "assets/lottie/arm_circles.json",
    time: "00:20",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "Leg Swings",
    filePath: "assets/images/leg_swing.png",
    time: "16 reps",
    isAnimation: false,
  ),
];

final Map<String, dynamic> warmupData = {
  "time": "00:50", // You can also write "50 sec" or calculate accurately
  "exerciseCount": warmupExercises.length.toString(),
  "exercises": warmupExercises,
};
