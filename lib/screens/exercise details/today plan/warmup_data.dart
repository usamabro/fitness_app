import 'package:fitness_app/full body/exercise_model.dart';

final List<ExerciseModel> warmupExercises = [
  ExerciseModel(
    name: "Jumping Jack",
    filePath: "assets/animation/Jumping Jack.json",
    time: "00:30",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "Abs Crunches",
    filePath: "assets/animation/push up.json",
    time: "x16",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "abs circles ",
    filePath: "assets/animation/Seated abs circles.json",
    time: "00:30",
    isAnimation: true,
  ),
  ExerciseModel(
    name: " Twist",
    filePath: "assets/animation/exercise 3.json",
    time: "x16",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "Russian ",
    filePath: "assets/animation/exercise 4.json",
    time: "x14",
    isAnimation: true,
  ),
];

final Map<String, dynamic> warmupData = {
  "time": "00:50", // You can also write "50 sec" or calculate accurately
  "exerciseCount": warmupExercises.length.toString(),
  "exercises": warmupExercises,
};
