import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/data.dart';
import 'package:mad_assignment_sp_consult_booking/historyPage.dart';
import 'package:mad_assignment_sp_consult_booking/homepage.dart';
import 'package:mad_assignment_sp_consult_booking/profile.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {

  List <Widget> pages = [HomePage(), HistoryPage(), ProfilePage()];

  int currentpage=0;

  @override
  Widget build(BuildContext context) {
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

      body: pages[currentpage],


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