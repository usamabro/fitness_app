import 'package:fitness_app/full%20body/daily_exercise_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FullBodyExerciseScreen extends StatefulWidget {
  const FullBodyExerciseScreen({Key? key}) : super(key: key);

  @override
  State<FullBodyExerciseScreen> createState() => _FullBodyExerciseScreenState();
}

class _FullBodyExerciseScreenState extends State<FullBodyExerciseScreen> {
  int? selectedDay;

  int completedDays = 0; // 🔥 Added missing variable

  int get totalDays => 28;
  double get progress => completedDays / totalDays;

  @override
  void initState() {
    super.initState();
    _loadCompletedDays(); // 🔥 Load Firebase progress
  }
  Future<void> markDayComplete(int dayNumber) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  String today = DateFormat('yyyy-MM-dd').format(DateTime.now()); // e.g. 2025-08-23

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  // Save completed day
  await userRef.collection('completedDays').doc(dayNumber.toString()).set({
    'day': dayNumber,
    'completedAt': FieldValue.serverTimestamp(),
  });

  // Check if today's date already counted for weekly goal
  final weeklyRef = userRef.collection('weeklyGoals').doc(today);
  final snapshot = await weeklyRef.get();

  if (!snapshot.exists) {
    // only add once per day
    await weeklyRef.set({
      'date': today,
      'counted': true,
    });
  }
}


  Future<void> _loadCompletedDays() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  setState(() {
    int activeDay = doc.data()?['currentDay'] ?? 1;
completedDays = activeDay - 1;
   
  });
}


  void _startDayWorkout() {
    int dayToStart = selectedDay ?? completedDays + 1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyExerciseScreen(
          dayKey: "Day $dayToStart",
          onComplete: () async {
           

            // Reload progress
            await _loadCompletedDays();

            setState(() {
              selectedDay = null;
            });
          },
        ),
      ),
    
    );
  }

  bool selectedDayProvidedAlreadyCompleted(int day) {
    return day <= completedDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200,
                leading: const BackButton(color: Colors.white),
                flexibleSpace: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.asset(
                        'assets/images/banner.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${totalDays - completedDays} Days left",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                "${(progress * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/trainers.png'),
                            radius: 25,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Kick off your full-body fitness journey with energy!",
                              style: TextStyle(fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildWeek("Week 1", 1),
                        _buildWeek("Week 2", 2),
                        _buildWeek("Week 3", 3),
                        _buildWeek("Week 4", 4),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                ]),
              ),
            ],
          ),

          /// ✅ Bottom GO button
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startDayWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  "GO",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeek(String title, int weekNumber) {
    int startDay = (weekNumber - 1) * 7 + 1;
    int endDay = startDay + 6;
    bool weekStarted = completedDays >= startDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt, color: Colors.blue),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Spacer(),
            Text(
              "${completedDays >= endDay ? 7 : (completedDays - startDay + 1).clamp(0, 7)}/7",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) {
              int dayTop = startDay + i;
              int dayBottom = startDay + 4 + i;

              Widget buildDayCircle(int day) {
                bool isCompleted = day <= completedDays;
                bool isCurrent   = day == completedDays + 1;

                return GestureDetector(
                  onTap: () {
                    if (!weekStarted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Start Exercise"),
                          content: const Text(
                              "Click the Go button to start your exercise."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      setState(() {
                        selectedDay = day;
                      });
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.blue : Colors.white,
                      border: Border.all(
                        color: isCompleted
                            ? Colors.transparent
                            : isCurrent
                                ? Colors.red
                                : Colors.grey,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$day",
                      style: TextStyle(
                        color: isCompleted ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              Widget top = buildDayCircle(dayTop);
              Widget bottom;

              if (i < 3) {
                bottom = buildDayCircle(dayBottom);
              } else {
                bottom = const Icon(Icons.emoji_events,
                    color: Colors.grey, size: 30);
              }

              return Column(
                children: [
                  top,
                  const SizedBox(height: 10),
                  bottom,
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
