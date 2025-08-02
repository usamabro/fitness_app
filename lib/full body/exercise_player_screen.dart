import 'package:fitness_app/screens/main%20screens/navbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'exercise_model.dart';
import 'rest_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final int startIndex;
  final bool isSingle;
  final String section;

  const ExercisePlayerScreen({
    super.key,
    required this.exercises,
    required this.startIndex,
    required this.isSingle,
    required this.section,
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

    _ensureUserSignedIn();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakInstruction(widget.exercises[currentIndex]);
    });
  }

  Future<void> _ensureUserSignedIn() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      print("✅ Signed in anonymously");
    }
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

  Future<void> saveExerciseToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ User is not signed in.");
        return;
      }

      final uid = user.uid;
      final exercise = widget.exercises[currentIndex];
      final int duration =
          exercise.durationInSeconds > 0 ? exercise.durationInSeconds : 40;

      print("🔥 Saving exercise to Firebase...");
      print("📝 Name: ${exercise.name}");
      print("⏱️ Duration: $duration sec");
      print("👤 UID: $uid");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('completedExercises')
          .doc(widget.section)
          .collection('exercises')
          .add({
        'exerciseName': exercise.name,
        'duration': duration,
        'section': widget.section,
        'timestamp': Timestamp.now(),
        'uid': uid,
      });

      await updateDailyReport(exercise, duration);

      print("✅ Exercise saved to Firebase.");
    } catch (e) {
      print("❌ Error saving exercise: $e");
    }
  }

  Future<void> updateDailyReport(ExerciseModel exercise, int duration) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final now = DateTime.now();
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('daily_reports')
        .doc(today);

    final reportSnapshot = await docRef.get();

    final kcal = (duration * 0.15).toInt();
    final newExerciseData = {
      'name': exercise.name,
      'duration': duration,
      'kcal': kcal,
      'timestamp': now.toIso8601String(),
    };

    if (reportSnapshot.exists) {
      final data = reportSnapshot.data()!;
      final updatedTime = (data['totalTime'] ?? 0) + duration;
      final updatedKcal = (data['totalKcal'] ?? 0) + kcal;
      final updatedWorkouts = (data['workouts'] ?? 0) + 1;

      List<dynamic> completed = List.from(data['completedExercises'] ?? []);
      bool alreadyAdded = completed.any((e) => e['name'] == exercise.name);
      if (!alreadyAdded) {
        completed.add(newExerciseData);
      }

      await docRef.update({
        'totalTime': updatedTime,
        'totalKcal': updatedKcal,
        'workouts': updatedWorkouts,
        'completedExercises': completed,
      });

      print("✅ Daily report updated for $today");
    } else {
      await docRef.set({
        'date': today,
        'totalTime': duration,
        'totalKcal': kcal,
        'workouts': 1,
        'dailyStreak': 1,
        'bestDayKcal': kcal,
        'completedExercises': [newExerciseData],
      });

      print("✅ Daily report updated for $today");
    }
  }

  void goToNextExercise() {
    tts.stop();

    if (widget.isSingle) {
      Navigator.pop(context);
      return;
    }

    if (currentIndex + 1 < widget.exercises.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RestScreen(
            exercises: widget.exercises,
            currentIndex: currentIndex,
            isSingle: false,
            section: widget.section,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("🎉 Congratulations!"),
          content: const Text("You’ve completed today’s exercise."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Navbar()),
                );
              },
              child: const Text("OK"),
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
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: Center(
              child: exercise.isAnimation
                  ? Lottie.asset(exercise.filePath, width: 200, height: 200)
                  : Image.asset(exercise.filePath, width: 200, height: 200),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "READY TO GO!",
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Text(
                    exercise.name,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  showReps
                      ? Text(exercise.time,
                          style:
                              const TextStyle(fontSize: 22, color: Colors.grey))
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
                                    value: value / exercise.durationInSeconds,
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
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await saveExerciseToFirebase();
                        goToNextExercise();
                      },
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
                            fontSize: 22, fontWeight: FontWeight.w600),
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
