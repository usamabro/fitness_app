import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/screens/chat%20screen/chat_screen.dart';
import 'package:flutter/material.dart';

class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? currentUserRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentUserRole();
  }

  Future<void> getCurrentUserRole() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    if (doc.exists) {
      setState(() {
        currentUserRole = doc.data()?['role'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String generateChatId(String uid1, String uid2) {
    return (uid1.compareTo(uid2) <= 0) ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Available Users")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Available Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final allUsers = snapshot.data!.docs;

          final filteredUsers = allUsers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final role = data['role'] ?? '';
            final docId = doc.id;
            return docId != currentUserId &&
                ((currentUserRole == 'trainer' && role == 'user') ||
                    (currentUserRole != 'trainer' && role == 'trainer'));
          }).toList();

          if (filteredUsers.isEmpty) {
            return Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final userData = user.data() as Map<String, dynamic>;
              final userName = userData['name'];
              final role = userData['role'] ?? 'user';
              final userId = user.id;
              final userEmail = userData['email'] ?? '';

              final displayName =
                  (userName != null && userName.toString().trim().isNotEmpty)
                      ? userName
                      : userEmail;

              final subtitleText = role == 'trainer'
                  ? 'Trainer: $userEmail'
                  : 'User: $userEmail';

              final chatId = generateChatId(currentUserId, userId);

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .snapshots(),
                builder: (context, chatSnapshot) {
                  int unreadCount = 0;
                  if (chatSnapshot.hasData && chatSnapshot.data!.exists) {
                    final data =
                        chatSnapshot.data!.data() as Map<String, dynamic>;
                    unreadCount = data['unread_$currentUserId'] ?? 0;
                  }

                  return ListTile(
                    leading: Icon(role == 'trainer'
                        ? Icons.fitness_center
                        : Icons.person),
                    title: Text(displayName),
                    subtitle: Text(subtitleText),
                    trailing: unreadCount > 0
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(peerId: userId, peerEmail: userEmail),
                        ),
                      );

                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .set({
                        'unread_$currentUserId': 0,
                      }, SetOptions(merge: true));

                      setState(() {});
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ✅ Add this function to register new users with default role "user"
Future<void> registerUser(String name, String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': 'user', // 👈 Default role
        'createdAt': Timestamp.now(),
      });
    }
  } catch (e) {
    print('Registration error: $e');
  }
}
