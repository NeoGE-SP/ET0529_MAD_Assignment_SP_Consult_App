import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mad_assignment_sp_consult_booking/homepage.dart';
import 'package:mad_assignment_sp_consult_booking/newConsult1.dart';
import 'package:mad_assignment_sp_consult_booking/newConsult2.dart';
import 'firebase_options.dart';
import 'bottomNav.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(MaterialApp(
    home: BottomNav(),
    //home: Newconsult1(),
    //home:Newconsult2(),

      routes: {
        "/HomePage": (context) => const HomePage(),
        "/newConsult1": (context) => const Newconsult1(),
        "/newConsult2": (context) => const Newconsult2(),

      },



  ));
}