import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mad_assignment_sp_consult_booking/bottomNav.dart';
import 'package:mad_assignment_sp_consult_booking/rescheduleConsult.dart';
import 'package:mad_assignment_sp_consult_booking/updateAvailability.dart';
import 'firebase_options.dart';
import 'package:mad_assignment_sp_consult_booking/login.dart';
import 'package:mad_assignment_sp_consult_booking/newConsult1.dart';
import 'package:mad_assignment_sp_consult_booking/newConsult2.dart';
import 'package:mad_assignment_sp_consult_booking/scheduleLecture.dart';
import 'package:mad_assignment_sp_consult_booking/scheduledConsults.dart';
import 'package:mad_assignment_sp_consult_booking/ai_summary.dart';
import 'package:mad_assignment_sp_consult_booking/newnotes.dart';
import 'package:mad_assignment_sp_consult_booking/notes.dart';
import 'package:mad_assignment_sp_consult_booking/reload.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized');
    } else {
      rethrow;
    }
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MaterialApp(
    home: Login(),

    routes: {
      "/login": (context) => const Login(),
      "/HomePage": (context) => BottomNav(),
      "/newConsult1": (context) => const Newconsult1(),
      "/notes": (context) => const NotesPage(),
      "/newNotes": (context) => const NewNotesPage(),
      "/newConsult2": (context) => const Newconsult2(),
      "/scheduleStudent": (context) => const ConfirmStudent(),
      "/scheduleLecture": (context) => const ConfirmLecture(),
      '/reschedConsult' : (context) => const Rescheduleconsult(),
      '/reload' : (context) => const Reload(),
      '/updateAvailability' : (context) => const UpdateAvailabilityPage(),
      '/aisummary' : (context) => const NoteSummarizer(),
    },
  ));
}

