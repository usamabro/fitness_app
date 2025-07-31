import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;

  ChatScreen({required this.peerId, required this.peerName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? currentUserId;
  late String chatId;

  @override
  void initState() {
    super.initState();
    initializeChat();
  }

  Future<void> initializeChat() async {
    final user = _auth.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      chatId = generateChatId(currentUserId!, widget.peerId);

      // ✅ Reset unread count on open
      await _firestore.collection('chats').doc(chatId).set({
        'unread_${currentUserId!}': 0,
      }, SetOptions(merge: true));

      setState(() {});
    }
  }

  String generateChatId(String uid1, String uid2) {
    return (uid1.compareTo(uid2) <= 0) ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  void sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty || currentUserId == null) return;

    try {
      List<String> sortedUsers = [currentUserId!, widget.peerId]..sort();

      await _firestore.collection('chats').doc(chatId).set({
        'users': sortedUsers,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'receiverId': widget.peerId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ Increase receiver’s unread count
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();
      final field = 'unread_${widget.peerId}';
      final prev = chatDoc.data()?[field] ?? 0;
      await chatRef.set({
        field: prev + 1,
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Error sending message: $e");
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.peerName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("❌ Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs
                    .where((doc) => doc['timestamp'] != null)
                    .toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Color(0xFF3366FF)
                              : Colors.grey[300], // Original blue
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
