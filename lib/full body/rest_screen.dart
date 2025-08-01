import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'exercise_model.dart';
import 'exercise_player_screen.dart';

class RestScreen extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final int currentIndex;
  final bool isSingle;

  const RestScreen({
    super.key,
    required this.exercises,
    required this.currentIndex,
    required this.isSingle,
  });

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  int _restSeconds = 20;
  late Timer _timer;
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakNextExercise();
    });
    _startRestTimer();
  }

  void _startRestTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds == 0) {
        _goToNextExercise();
      } else {
        setState(() {
          _restSeconds--;
        });
      }
    });
  }

  void _speakNextExercise() async {
    final nextExercise = widget.exercises[widget.currentIndex + 1];

    String message = nextExercise.durationInSeconds > 0
        ? "Next exercise: ${nextExercise.name} for ${nextExercise.durationInSeconds} seconds"
        : "Next exercise: ${nextExercise.name} for ${nextExercise.time}";

    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    await tts.awaitSpeakCompletion(true); // ✅ important
    await tts.speak(message);
  }

  void _goToNextExercise() {
    _timer.cancel();
    tts.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExercisePlayerScreen(
          exercises: widget.exercises,
          startIndex: widget.currentIndex + 1,
          isSingle: widget.isSingle, // ✅ go to next
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextExercise = widget.exercises[widget.currentIndex + 1];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: Center(
              child: nextExercise.isAnimation
                  ? Lottie.asset(
                      nextExercise.filePath,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      nextExercise.filePath,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${widget.currentIndex + 2} / ${widget.exercises.length}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nextExercise.name,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  // 🔸 Center: "Rest" text and timer
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "REST",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${_restSeconds}s",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 🔘 Buttons: +20s and Skip (60% width each)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.38,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _restSeconds += 20;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            "+20s",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.38,
                        child: ElevatedButton(
                          onPressed: _goToNextExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
