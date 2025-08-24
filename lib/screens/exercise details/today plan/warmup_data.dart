import 'package:fitness_app/full body/exercise_model.dart';

final List<ExerciseModel> warmupExercises = [
  ExerciseModel(
    name: "Jumping Jack",
    filePath: "assets/animation/Jumping Jack.json",
    time: "00:30",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "Jumping Squats",
    filePath: "assets/animation/Jumping_squats.json",
    time: "x16",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "Milltary Push Ups ",
    filePath: "assets/animation/Military Push Ups.json",
    time: "x10",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "Mountain Climbers",
    filePath: "assets/animation/mountain climbers.json",
    time: "x14",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "one-leg raise",
    filePath: "assets/animation/one-leg raise.json",
    time: "x14",
    isAnimation: true,
  ),
 
  ExerciseModel(
    name: "plank ",
    filePath: "assets/images/plank.png",
    time: "1 :00",
    isAnimation: false,
  ),
  ExerciseModel(
    name: "well abs stretch",
    filePath: "assets/images/wall stretch.jpg",
    time: "00 : 30",
    isAnimation: false,
  ),
  ExerciseModel(
    name: "leg stratch to chest",
    filePath: "assets/images/leg stratch to chest.jpg",
    time: "00 : 30",
    isAnimation: false,
  ),
];

final Map<String, dynamic> warmupData = {
  "time": "8:00", // You can also write "50 sec" or calculate accurately
  "exerciseCount": warmupExercises.length.toString(),
  "exercises": warmupExercises,
};
