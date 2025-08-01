import 'package:fitness_app/screens/main%20screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'exercise_model.dart';
import 'rest_screen.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final int startIndex;
  final bool isSingle;

  const ExercisePlayerScreen({
    super.key,
    required this.exercises,
    required this.startIndex,
    required this.isSingle,
  });

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  late int currentIndex;
  bool showReps = false;
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
    showReps = widget.exercises[currentIndex].durationInSeconds == 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakInstruction(widget.exercises[currentIndex]);
    });
  }

  void _speakInstruction(ExerciseModel exercise) async {
    String message = exercise.durationInSeconds > 0
        ? "Ready to go ${exercise.durationInSeconds} seconds ${exercise.name}"
        : "Ready to go ${exercise.time} ${exercise.name}";

    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    await tts.awaitSpeakCompletion(true);
    await tts.speak(message);
  }

  void goToNextExercise() {
    tts.stop();

    // ✅ If it's a single exercise, just pop
    if (widget.isSingle) {
      Navigator.pop(context);
      return;
    }

    // ✅ If more exercises left, go to RestScreen
    if (currentIndex + 1 < widget.exercises.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RestScreen(
            exercises: widget.exercises,
            currentIndex: currentIndex,
            isSingle: false,
          ),
        ),
      );
    } else {
      // ✅ End of workout — show dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(
            "🎉 Congratulations!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("You’ve completed today’s exercise."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Navbar()),
                );
              },
              child: const Text("OK",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercises[currentIndex];

    return Scaffold(
      body: Column(
        children: [
          // 🔺 Top Half - White with centered animation/image
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: Center(
              child: exercise.isAnimation
                  ? Lottie.asset(
                      exercise.filePath,
                      width: 200,
                      height: 200,
                    )
                  : Image.asset(
                      exercise.filePath,
                      width: 200,
                      height: 200,
                    ),
            ),
          ),

          // 🔻 Bottom Half
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "READY TO GO!",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // 🔹 Timer or Reps
                  showReps
                      ? Text(
                          exercise.time,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.grey,
                          ),
                        )
                      : TweenAnimationBuilder(
                          tween: Tween<double>(
                              begin: exercise.durationInSeconds.toDouble(),
                              end: 0),
                          duration:
                              Duration(seconds: exercise.durationInSeconds),
                          onEnd: goToNextExercise,
                          builder: (context, value, _) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: value /
                                        exercise.durationInSeconds.toDouble(),
                                    strokeWidth: 10,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.redAccent,
                                  ),
                                ),
                                Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                  const SizedBox(height: 40),

                  // 🔹 Done Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: goToNextExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
