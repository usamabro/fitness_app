import 'package:fitness_app/screens/auth/register/name_screen.dart';
import 'package:fitness_app/screens/auth/register/weekly_goal_screen.dart';
import 'package:fitness_app/screens/auth/reset_password.dart';
import 'package:fitness_app/screens/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFB31919),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            settingsCard(
              icon: Icons.person,
              title: "Edit Profile",
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => NameScreen())),
            ),
            settingsCard(
              icon: Icons.calendar_today,
              title: "Update Workout Plan",
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => WeeklyGoalScreen())),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: EdgeInsets.only(bottom: 16),
              child: SwitchListTile(
                secondary: Icon(Icons.notifications, color: Colors.black),
                title: Text("Notifications", style: TextStyle(fontSize: 16)),
                value: notificationsEnabled,
                onChanged: (val) {
                  setState(() => notificationsEnabled = val);
                  // Later: save to SharedPreferences
                },
              ),
            ),
            settingsCard(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.email != null) {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: user.email!);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPassword(),
                      ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User email not found")),
                  );
                }
              },
            ),
            settingsCard(
              icon: Icons.logout,
              title: "Logout",
              onTap: () async {
                final confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("No"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Yes"),
                      ),
                    ],
                  ),
                );
                if (confirmLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => SigninScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            settingsCard(
              icon: Icons.delete_forever,
              title: "Delete Account",
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () async {
                final confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Delete Account"),
                    content: Text(
                        "Are you sure you want to delete your account?\nAll your data will be deleted."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("No"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Yes"),
                      ),
                    ],
                  ),
                );
                if (confirmDelete == true) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    try {
                      await user.delete();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => SigninScreen()),
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Account deleted successfully")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Error: Re-login required to delete account"),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
