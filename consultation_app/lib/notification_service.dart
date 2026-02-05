import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class NotificationService {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token;
    String? userId;

    void requestNotificationPermission() async {
        NotificationSettings settings = await messaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            log("Permission granted by user");
        }
        else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
            log("Permission granted provisionally");
        } else {
            log("Permission denied");
        }
    }

    Future<String> getFcmToken() async {
        token = await messaging.getToken();
        log("Token: $token");
        return token!;
    }

    Future<void> saveFcmToken(String userId) async {
    String? token = await messaging.getToken();
    await FirebaseFirestore.instance.collection("consultationData").doc(userId).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }
}