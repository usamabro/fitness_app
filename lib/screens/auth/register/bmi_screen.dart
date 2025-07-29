import 'package:fitness_app/screens/auth/register/weekly_goal_screen.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BMIScreen extends StatelessWidget {
  final double bmi;

  BMIScreen({required this.bmi});

  // Suggestion based on BMI
  String getBMICategory() {
    if (bmi < 18.5) return "Underweight";
    if (bmi >= 18.5 && bmi < 25) return "Normal weight";
    if (bmi >= 25 && bmi < 30) return "Overweight";
    return "Obese";
  }

  String getSuggestion() {
    if (bmi < 18.5) return "Eat more calories and try strength training.";
    if (bmi >= 18.5 && bmi < 25)
      return "Maintain a balanced diet and regular exercise.";
    if (bmi >= 25 && bmi < 30)
      return "Focus on cardio and reduce calorie intake.";
    return "Consult a fitness expert for weight loss plan.";
  }

  String getMotivationQuote() {
    return "Push yourself because no one else is going to do it for you.";
  }

  Future<void> saveBMIToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'bmi': bmi,
          'bmiCategory': getBMICategory(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error saving BMI: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    saveBMIToFirebase(); // Call on screen build

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BMI Result",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white, size: 30),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your BMI is",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              bmi.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              getBMICategory(),
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 30),
            Text(
              getSuggestion(),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Divider(),
            Text(
              "💪 Motivation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              getMotivationQuote(),
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeeklyGoalScreen(),
                      ));
                  // Replace with your actual next screen
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => YourNextScreen()));
                  print("Continue pressed"); // temporary placeholder
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.red,
                ),
                child: Text("Continue",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
