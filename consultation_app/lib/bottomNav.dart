import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/historyPage.dart';
import 'package:mad_assignment_sp_consult_booking/studentHome.dart';
import 'package:mad_assignment_sp_consult_booking/lectureHome.dart';
import 'package:mad_assignment_sp_consult_booking/lectureProfile.dart';
import 'package:mad_assignment_sp_consult_booking/lecturerPastConsult.dart';
import 'package:mad_assignment_sp_consult_booking/studentProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  String? roleFound;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  List pageSelect = [];

  List <Widget> pagesStudent = [HomePage(), HistoryPage(), ProfilePage()];
  List <Widget> pagesLecture = [LectureHome(), LectureHistoryPage(), LectureProfilePage()];

  int currentpage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    Future.microtask(() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      setState(() {
        currentpage = args;
      });
    }
  });
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

  if (roleFound == 'students') {
    setState(() {
      pageSelect = pagesStudent;
    });
  }
  if (roleFound == 'lecturers') {
    setState(() {
      pageSelect = pagesLecture;
    });
  }
}

  @override
  Widget build(BuildContext context) {

    if (isLoading || pageSelect.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset('assets/img/sp_logo.png', height: 40, fit: BoxFit.contain,),
        shape: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 195, 195, 195),
            width: 2,
          ),
        ),
      ),

      body: pageSelect[currentpage],


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentpage,
        onTap: (value) {
          setState(() {
            currentpage = value;
          });
        },
        items: const [
           BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Consult History'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'
          )
        ],
      ),
    );
  }
}