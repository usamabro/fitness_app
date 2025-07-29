import 'package:fitness_app/full body/exercise_model.dart';

final List<ExerciseModel> cooldownExercises = [
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
      ExerciseModel(
        name: "Russian Twist",
        filePath: "assets/animation/exercise 5.json",
        time: "00:30",
        isAnimation: true,
      ),
      ExerciseModel(
        name: "exercise",
        filePath: "assets/animation/exercise.json",
        time: "x18",
        isAnimation: true,
      ),
];

final Map<String, dynamic> cooldownData = {
  "time": "00:50", // You can also write "50 sec" or calculate accurately
  "exerciseCount": cooldownExercises.length.toString(),
  "exercises": cooldownExercises,
};
