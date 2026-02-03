import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mad_assignment_sp_consult_booking/notification_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _loginUsername = TextEditingController();
  final TextEditingController _loginPassword = TextEditingController();
  String? selectedValue;

  void signIn() async {
    String username = _loginUsername.text.trim();
    String password = _loginPassword.text.trim();

    final messenger = ScaffoldMessenger.of(context);

    if (username.isEmpty || password.isEmpty || selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields and select a role'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      String role = selectedValue.toString();
      final query = await FirebaseFirestore.instance
          .collection(role)
          .where('adm', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("User not found");
      }

      final email = query.docs.first['email'];

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      NotificationService notificationService = NotificationService();
      String fcmToken = await notificationService.getFcmToken();

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Signed in successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDocRef = FirebaseFirestore.instance
          .collection(role) 
          .doc(user.uid);

        await userDocRef.set({
          'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        }, SetOptions(merge: true));

        print('FCM token added to user document successfully!');
      }

    } catch(e) {
      if (!mounted) return;
      
      messenger.showSnackBar(
        SnackBar(
          content: Text("Username, Password or Role is incorrect"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    NotificationService notificationService = NotificationService();
    notificationService.requestNotificationPermission();
    notificationService.getFcmToken();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/HomePage');
        });
      }
    }
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( 
          child: Column(
            children: [
              SizedBox(height: 80),
              Image.asset("assets/img/sp_logo.png", height: 100),
              SizedBox(height: 80),
              Text("Username", style: TextStyle(fontSize: 20)),
              Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
                child: TextField(
                  controller: _loginUsername,
                  decoration: InputDecoration(
                    labelText: "S/PXXXXXXX",
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                ),
              ),
              Text("Password", style: TextStyle(fontSize: 20)),
              Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
                child: TextField(
                  controller: _loginPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text("I am a (student/lecturer)", style: TextStyle(fontSize: 20)),
              DropdownMenu<String>(
                width: 250,
                label: const Text('Select role'),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'students', label: 'Student'),
                  DropdownMenuEntry(value: 'lecturers', label: 'Lecturer'),
                ],
                onSelected: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: signIn,
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                child: Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
