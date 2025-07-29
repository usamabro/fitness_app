import 'exercise_model.dart';

final Map<String, dynamic> dailyExerciseData = {
  "Day 1": {
    "time": "9 mins",
    "exerciseCount": "11 ",
    "exercises": [
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
      ExerciseModel(
        name: "Russian Twist",
        filePath: "assets/images/facebook.png",
        time: "00:30",
        isAnimation: false,
      ),
    ],
  },
  "Day 2": {
    "time": "9 mins",
    "exerciseCount": "11 ",
    "exercises": [
      ExerciseModel(
        name: "Jumping Jacks",
        filePath: "assets/images/facebook.png",
        time: "00:30",
        isAnimation: true,
      ),
      ExerciseModel(
        name: "Abs Crunches",
        filePath: "assets/images/abs_intar.png",
        time: "x16",
        isAnimation: true,
      ),
      ExerciseModel(
        name: "Russian Twist",
        filePath: "assets/images/abs_advan.png",
        time: "00:30",
        isAnimation: true,
      ),
      // Add more exercises if needed
    ],
  },
};
