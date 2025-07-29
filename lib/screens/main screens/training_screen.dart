import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/screens/exercise%20details/today%20plan/cool_down_screen.dart';
import 'package:fitness_app/screens/exercise%20details/today%20plan/full_body_exercise_screen.dart';
import 'package:fitness_app/screens/exercise%20details/today%20plan/warm_up_screen.dart';
import 'package:fitness_app/screens/main%20screens/exercise_data.dart';
import 'package:fitness_app/screens/main%20screens/exerciselist_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/screens/auth/register/weekly_goal_screen.dart';

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final Map<String, List<Map<String, dynamic>>> focusWorkouts = {
    "Abs": [
      {
        "title": "Abs Beginner",
        "duration": "20 mins",
        "exercises": "16 Exercises",
        "image": "assets/images/abs.png",
        "difficulty": 1,
      },
      {
        "title": "Abs Intermediate",
        "duration": "29 mins",
        "exercises": "21 Exercises",
        "image": "assets/images/abs_intar.png",
        "difficulty": 2,
      },
      {
        "title": "Abs Advanced",
        "duration": "36 mins",
        "exercises": "21 Exercises",
        "image": "assets/images/abs_advan.png",
        "difficulty": 3,
      },
    ],
    "Arm": [
      {
        "title": "Arm Beginner",
        "duration": "15 mins",
        "exercises": "10 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 1,
      },
      {
        "title": "Arm Intermediate",
        "duration": "25 mins",
        "exercises": "18 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 2,
      },
      {
        "title": "Arm Advanced",
        "duration": "25 mins",
        "exercises": "18 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 2,
      },
    ],
    "Chest": [
      {
        "title": "Chest Beginner",
        "duration": "18 mins",
        "exercises": "12 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 1,
      },
      {
        "title": "Chest Intermediate",
        "duration": "18 mins",
        "exercises": "12 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 1,
      },
      {
        "title": "Chest Advanced",
        "duration": "18 mins",
        "exercises": "12 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 1,
      },
    ],
    "Leg": [
      {
        "title": "Leg Beginner",
        "duration": "30 mins",
        "exercises": "20 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 2,
      },
      {
        "title": "Leg Intermediate",
        "duration": "30 mins",
        "exercises": "20 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 2,
      },
      {
        "title": "Leg Advanced",
        "duration": "30 mins",
        "exercises": "20 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 2,
      },
    ],
    "Shoulder": [
      {
        "title": "  Shoulder Beginner ",
        "duration": "22 mins",
        "exercises": "14 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 2,
      },
      {
        "title": "Shoulder  Intermediate",
        "duration": "22 mins",
        "exercises": "14 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 2,
      },
      {
        "title": "Shoulder Advanced",
        "duration": "22 mins",
        "exercises": "14 Exercises",
        "image": "assets/images/men.png",
        "difficulty": 2,
      },
    ],
  };

  String selectedFocus = "Abs";
  final Color primary = Color(0xFFB31919);
  List<String> selectedDays = [];
  int weeklyGoal = 0;

  @override
  void initState() {
    super.initState();
    loadWeeklyGoal();
  }

  void loadWeeklyGoal() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            if (data['weekly_goal_days'] != null) {
              selectedDays = List<String>.from(data['weekly_goal_days']);
            }
            if (data['weekly_goal'] != null) {
              weeklyGoal = data['weekly_goal'];
            }
          });
        }
      }
    }
  }

  void _editDays() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WeeklyGoalScreen()),
    );
    if (result != null) {
      setState(() {
        selectedDays = List<String>.from(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().day.toString();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("HOME WORKOUT",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Icon(Icons.local_fire_department, color: primary),
                ],
              ),
              const SizedBox(height: 10),

              // Weekly Goal Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Weekly goal",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text("0/$weeklyGoal"),
                        IconButton(
                            onPressed: _editDays,
                            icon: Icon(Icons.edit, size: 18)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final day = date.day.toString();
                        final isSelected =
                            selectedDays.contains(day) || day == today;

                        return CircleAvatar(
                          backgroundColor:
                              isSelected ? primary : Colors.grey.shade200,
                          child: Text(day,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black)),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage('assets/images/google.png')),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text(
                                "Hi, my friend! Let’s continue crushing your goals!")),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Today's Plan Section
              Text("Today's Plan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),

              Column(
                children: [
                  _routineCard("Full body Exercise", "Full body strength",
                      "28 Days", Icons.accessibility_new),
                  const SizedBox(height: 10),
                  _routineCard("Warm-up", "Stretching & light cardio",
                      "20 mins", Icons.fitness_center),
                  const SizedBox(height: 10),
                  _routineCard("Cooldown", "Relaxing stretches", "8 mins",
                      Icons.self_improvement),
                ],
              ),

              const SizedBox(height: 20),
              Text("Body Focus",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              _bodyFocusSection(),
              // Workout List Section
              const SizedBox(height: 20),
              Text("Workout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              _workoutListSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routineCard(
      String title, String desc, String duration, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == "Full body Exercise") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullBodyExerciseScreen(),
              ));
        } else if (title == "Warm-up") {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const WarmupScreen()));
        } else if (title == "Cooldown") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CoolDownScreen()));
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6,
                offset: Offset(2, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(desc, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            Column(
              children: [
                Text(duration,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    if (title == "Full body Exercise") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FullBodyExerciseScreen()),
                      );
                    } else if (title == "Warm-up") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WarmupScreen()),
                      );
                    } else if (title == "Cooldown") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CoolDownScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: Size(60, 30),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text("Start",
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyFocusSection() {
    final List<String> focus = [
      "Abs",
      "Arm",
      "Chest",
      "Leg",
      "Shoulder",
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: focus.map((item) {
          final isActive = item == selectedFocus;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFocus = item;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(item),
                backgroundColor: isActive ? primary : Colors.grey.shade200,
                labelStyle:
                    TextStyle(color: isActive ? Colors.white : Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide.none,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _workoutListSection() {
    final List<Map<String, dynamic>> workouts =
        focusWorkouts[selectedFocus] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "$selectedFocus Workouts",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        ...workouts.map((workout) {
          return GestureDetector(
            onTap: () {
              String title = workout['title'] as String;
              List<Map<String, String>> exercises = exerciseData[title] ?? [];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseListScreen(
                    title: title,
                    exercises: exercises,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      workout["image"],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${workout['duration']} • ${workout['exercises']}",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey[600]),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
