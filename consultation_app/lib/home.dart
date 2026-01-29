import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
    bool _isLoading = false;

    Future<void> _getNotif(token, docID, role) async {
      setState(() {
        _isLoading = true;
      });


      final url = Uri.parse('http://10.0.2.2:3000/getnotif');

      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'token': token,
          'docID': docID,
          'role': role,
        })
      );

      setState(() {
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final role = args['role'];
    Map<String, dynamic> userData = args['userData'];
    final token = args['token'];
    final userID = args['userID'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Push Notifications Test"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(child: Text("This is Push Notifications Test")),
          Center(child: _isLoading ? const CircularProgressIndicator() :
            TextButton(onPressed: () {_getNotif(token, userID, role);}, child: Text("Get Push Notif"))
          )
        ],
      ),
    );
  }
}