import 'package:fitness_app/full body/exercise_model.dart';

final List<ExerciseModel> cooldownExercises = [
  ExerciseModel(
    name: "Jumping Jack",
    filePath: "assets/animation/Jumping Jack.json",
    time: "00:30",
    isAnimation: true,
  
  ),
   ExerciseModel(
    name: "Seated  Abs Circle",
    filePath: "assets/animation/Seated abs circles.json",
    time: "x12",
    isAnimation: true,
  ),
  

  ExerciseModel(
    name: "Push Ups",
    filePath: "assets/animation/push ups.json",
    time: "x10",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "russain twist",
    filePath: "assets/animation/russain twist.json",
    time: "00:40",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "One-leg raise",
    filePath: "assets/animation/one-leg raise.json",
    time: "00:40",
    isAnimation: true,
  ),
  ExerciseModel(
    name: "Flexibility",
    filePath: "assets/images/cool down.png",
    time: "00:40",
    isAnimation: false,
  ),
  ExerciseModel(
    name: "Side Kick",
    filePath: "assets/images/side kick.png",
    time: "00:40",
    isAnimation: false,
  ),
  ExerciseModel(
    name: "plank",
    filePath: "assets/images/plank.png",
    time: "00:40",
    isAnimation: false,
  ),
  
 
];

final Map<String, dynamic> cooldownData = {
  "time": "08:00", // You can also write "50 sec" or calculate accurately
  "exerciseCount": cooldownExercises.length.toString(),
  "exercises": cooldownExercises,
};
