import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mad_assignment_sp_consult_booking/notification_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;
  String? roleFound;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load both profile image and other user fields from Firestore
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
          print(data);
          roleFound = col;
          break; // Stop once we find the document
        }
      }

      if (data != null) {
        setState(() {
          userData = data;
          userData!['role'] = roleFound; // store the role as well
          print(roleFound);
          print(userData!['fcmTokens']);
          print(userData!['email']);
          print(userData!['class']);
          isLoading = false;
        });
      } 
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => isLoading = false);
    }
  }

    Future<void> _getNotif() async {
      setState(() {
        _isLoading = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final url = Uri.parse('https://triaryl-thi-unobliged.ngrok-free.dev/requestnotif');

      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'token': userData!['fcmTokens'],
          'docID': user.uid,
          'role': roleFound.toString(),
        })
      );

      setState(() {
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: Text("Push Notifications Test"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(child: Text("This is Push Notifications Test")),
          Center(child: _isLoading ? const CircularProgressIndicator() :
            TextButton(onPressed: () {_getNotif();}, child: Text("Get Push Notif"))
          )
        ],
      ),
    );
  }
}