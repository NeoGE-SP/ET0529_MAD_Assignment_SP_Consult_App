import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MaterialApp(
    home: Login(),

    // routes: {
    //   "/newpage": (context) => const NewPage(),

    // },
  ));
}

