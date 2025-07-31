import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/screens/chat%20screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<void> _pickAndUploadImage(String userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$userId.jpg');

      await ref.putFile(File(pickedFile.path));
      final uploadedUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'imageUrl': uploadedUrl});

      setState(() {});
    }
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
              final userName = userData['name'] ?? 'No Name';
              final role = userData['role'] ?? 'user';
              final imageUrl = userData['imageUrl'];
              final userId = user.id;
              final userEmail = userData['email'] ?? '';

              final displayName =
                  userName.trim().isNotEmpty ? userName : userEmail;
              final subtitleText = role == 'trainer' ? 'Trainer' : 'User';

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
                    leading: GestureDetector(
                      onTap: () async {
                        if (userId == currentUserId) {
                          await _pickAndUploadImage(userId);
                        }
                      },
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  imageUrl != null && imageUrl.isNotEmpty
                                      ? NetworkImage(imageUrl)
                                      : AssetImage(
                                          role == 'trainer'
                                              ? 'assets/images/trainer.png'
                                              : 'assets/images/users.jpg',
                                        ) as ImageProvider,
                            ),
                            if (userId == currentUserId)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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
                              ChatScreen(peerId: userId, peerName: userName),
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

// ✅ Registration helper (unchanged)
Future<void> registerUser(String name, String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': 'user',
        'createdAt': Timestamp.now(),
      });
    }
  } catch (e) {
    print('Registration error: $e');
  }
}
