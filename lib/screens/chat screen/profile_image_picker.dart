import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePickerScreen extends StatefulWidget {
  @override
  _ProfileImagePickerScreenState createState() =>
      _ProfileImagePickerScreenState();
}

class _ProfileImagePickerScreenState extends State<ProfileImagePickerScreen> {
  File? _pickedImage;
  bool _isUploading = false;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (_pickedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');

      await ref.putFile(_pickedImage!);

      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'imageUrl': imageUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed")),
      );
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pick Profile Image")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _pickedImage != null
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(_pickedImage!),
                  )
                : CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 50),
                  ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text("Pick from Gallery"),
              onPressed: pickImage,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isUploading ? null : uploadImage,
              child: _isUploading
                  ? CircularProgressIndicator()
                  : Text("Upload & Save"),
            ),
          ],
        ),
      ),
    );
  }
}
