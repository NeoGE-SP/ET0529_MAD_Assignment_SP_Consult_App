import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

    final url = Uri.parse('http://10.0.2.2:3000/login');
    Map<String, dynamic> body = {
      'username': username,
      'password': password,
      'role': selectedValue,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return; 

      try {
        final resBody = jsonDecode(response.body);
        String message = resBody['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
            duration: Duration(seconds: 2),
          ),
        );

        // Optional: Navigate to another page on success
        // if (response.statusCode == 200) {
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
        // }

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected server response:\n${response.body}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to server'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( 
          child: Column(
            children: [
              SizedBox(height: 80),
              Image.asset("assets/images/SP.png", height: 100),
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