import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad_assignment_sp_consult_booking/notification_service.dart';

class LectureProfilePage extends StatefulWidget {
  const LectureProfilePage({super.key});

  @override
  State<LectureProfilePage> createState() => _LectureProfilePageState();
}

class _LectureProfilePageState extends State<LectureProfilePage> {
  File? _imageFile;
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  String? roleFound;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  Map<String, dynamic>? data;

  try {
    final collections = ['students', 'lecturers'];

    for (String col in collections) {
      final doc = await FirebaseFirestore.instance.collection(col).doc(user.uid).get();
      if (doc.exists) {
        data = doc.data();
        roleFound = col;
        break; 
      }
    }

    if (data != null) {
      
      final base64String = data['profileImageBase64'];
      if (base64String != null && base64String.isNotEmpty) {
        try {
          _profileImageBytes = base64Decode(base64String);
        } catch (e) {
          print("Failed to decode profile image: $e");
          _profileImageBytes = null; 
        }
      }

      setState(() {
        userData = data;
        userData!['role'] = roleFound; 
        print(roleFound);
        isLoading = false;
      });
    } else {
      print("User document not found in any collection!");
      setState(() => isLoading = false);
    }
  } catch (e) {
    print("Error loading user data: $e");
    setState(() => isLoading = false);
  }
}

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (pickedFile != null) {
                    final file = File(pickedFile.path);
                    setState(() => _imageFile = file);
                    await _saveImageToFirestore(file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (pickedFile != null) {
                    final file = File(pickedFile.path);
                    setState(() => _imageFile = file);
                    await _saveImageToFirestore(file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveImageToFirestore(File file) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw 'Could not decode image';

      final resized = img.copyResize(image, width: 500, height: 500);
      final compressedBytes = img.encodeJpg(resized, quality: 80);
      final base64Image = base64Encode(compressedBytes);

      await FirebaseFirestore.instance
          .collection(roleFound.toString())
          .doc(user.uid)
          .set({'profileImageBase64': base64Image}, SetOptions(merge: true));

      if (!mounted) return;

      setState(() => _profileImageBytes = compressedBytes);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to update image')));
    }
  }

  Future<void> signOut() async {
      NotificationService notificationService = NotificationService();
      String fcmToken = await notificationService.getFcmToken();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection(roleFound.toString()) 
          .doc(user.uid)
          .update({
            "fcmTokens": FieldValue.arrayRemove([fcmToken])
      });
      await FirebaseAuth.instance.signOut();
    }

  @override
  Widget build(BuildContext context) {

    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color.fromARGB(255, 214, 214, 214),
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : _profileImageBytes != null
                      ? MemoryImage(_profileImageBytes!)
                      : const AssetImage('assets/img/sp_logo.png') as ImageProvider,
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: const Color.fromARGB(255, 255, 239, 192),
              ),
              onPressed: _pickImage,
              child: const Text(
                'Edit Profile Picture',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 255, 153, 146),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person, 'Name', userData!['name']),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.badge, 'Adm. No.', userData!['adm']),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.email, 'Email', userData!['email']),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'For more info, click ',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'here',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 86, 156),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text('to access SAS.'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15,),
            ElevatedButton(
              onPressed: () async {
                await signOut();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(value, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ],
    );
  }
}