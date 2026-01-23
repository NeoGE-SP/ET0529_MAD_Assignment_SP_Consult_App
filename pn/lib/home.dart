import 'package:flutter/material.dart';
import 'package:pn/notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
    bool _isLoading = false;

    Future<void> _getNotif() async {
      setState(() {
        _isLoading = true;
      });


      final url = Uri.parse('http://10.0.2.2:3000/getnotif');

      // You can send an empty body or some default data
      await http.post(
        url,
      );

      setState(() {
        _isLoading = false;
      });
  }


  @override
  void initState() {
    NotificationService notificationService = NotificationService();
    notificationService.requestNotificationPermission();
    notificationService.getFcmToken();
    super.initState();
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
            TextButton(onPressed: _getNotif, child: Text("Get Push Notif"))
          )
        ],
      ),
    );
  }
}