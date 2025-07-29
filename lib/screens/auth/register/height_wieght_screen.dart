import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bmi_screen.dart';

class HeightWeightScreen extends StatefulWidget {
  const HeightWeightScreen({Key? key}) : super(key: key);

  @override
  _HeightWeightScreenState createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends State<HeightWeightScreen> {
  double heightCm = 160;
  double weightKg = 60;
  String heightUnit = 'cm';
  String weightUnit = 'kg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Height & Weight",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Your Height",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: heightUnit == 'cm' ? 100 : 3,
                    max: heightUnit == 'cm' ? 220 : 7,
                    value: heightCm,
                    onChanged: (value) {
                      setState(() {
                        heightCm = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  color: Colors.black,
                  fillColor: Colors.red,
                  isSelected: [
                    heightUnit == 'cm',
                    heightUnit == 'ft',
                  ],
                  onPressed: (index) {
                    setState(() {
                      heightUnit = index == 0 ? 'cm' : 'ft';
                      heightCm = heightUnit == 'cm'
                          ? 160
                          : double.parse((160 / 30.48).toStringAsFixed(1));
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("CM"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("FT"),
                    ),
                  ],
                ),
              ],
            ),
            Center(
              child: Text(
                heightUnit == 'cm'
                    ? '${heightCm.toStringAsFixed(0)} cm'
                    : '${heightCm.toStringAsFixed(1)} ft',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Select Your Weight",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: weightUnit == 'kg' ? 30 : 66,
                    max: weightUnit == 'kg' ? 150 : 330,
                    value: weightKg,
                    onChanged: (value) {
                      setState(() {
                        weightKg = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  color: Colors.black,
                  fillColor: Colors.red,
                  isSelected: [
                    weightUnit == 'kg',
                    weightUnit == 'lbs',
                  ],
                  onPressed: (index) {
                    setState(() {
                      weightUnit = index == 0 ? 'kg' : 'lbs';
                      weightKg = weightUnit == 'kg'
                          ? 60
                          : double.parse((60 * 2.20462).toStringAsFixed(0));
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("KG"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("LBS"),
                    ),
                  ],
                ),
              ],
            ),
            Center(
              child: Text(
                weightUnit == 'kg'
                    ? '${weightKg.toStringAsFixed(0)} kg'
                    : '${weightKg.toStringAsFixed(0)} lbs',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _saveDataAndNavigate,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _saveDataAndNavigate() async {
    double heightInMeters =
        heightUnit == 'cm' ? heightCm / 100 : (heightCm * 30.48) / 100;

    double weightInKg = weightUnit == 'kg' ? weightKg : weightKg / 2.20462;

    double bmiValue = weightInKg / (heightInMeters * heightInMeters);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'height': heightCm,
        'height_unit': heightUnit,
        'weight': weightKg,
        'weight_unit': weightUnit,
        'bmi': bmiValue,
      }, SetOptions(merge: true));
    }

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BMIScreen(
                bmi: bmiValue,
              )),
    );
  }
}
