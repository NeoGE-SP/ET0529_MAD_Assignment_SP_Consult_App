import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LectureHome extends StatefulWidget {
  const LectureHome({super.key});

  @override
  State<LectureHome> createState() => _LectureHomeState();
}

class _LectureHomeState extends State<LectureHome> {
  String? roleFound;
  String? nameFound;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load both profile image and other user fields from Firestore
  Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  Map<String, dynamic>? data;

  try {
    final collections = ['students', 'lecturers'];

    // Try fetching from each collection
    for (String col in collections) {
      final doc = await FirebaseFirestore.instance.collection(col).doc(user.uid).get();
      if (doc.exists) {
        data = doc.data();
        roleFound = col;
        break; // Stop once we find the document
      }
    }

    if (data != null) {
      setState(() {
        userData = data;
        userData!['role'] = roleFound;
        nameFound = userData!['name'];

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
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          
          children: [
            const Padding(padding: EdgeInsetsGeometry.all(10)),
            Text(
              'Welcome, $nameFound!', //add variable here for name from firebase
              style: TextStyle(fontSize:30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5,),

            const Text('What would you like to do today?', style: TextStyle(fontSize: 15),),

            const SizedBox(height: 30,),


             Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/scheduleLecture');
                },
                splashColor: Colors.black26,
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Ink.image(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/img/consults.png'),
                    height: 200,
                    width: 500,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstIn),
                    
                  ),

                  Text('Review Consultation Requests', style: TextStyle(fontSize:30, fontWeight: FontWeight.bold)),
                  
                  ]
                ),
              
              ),
            ),

            SizedBox(height: 20,),           

            Expanded(
              child: InkWell(
                onTap: () {
                },
                splashColor: Colors.black26,
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Ink.image(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/img/schedule.png'),
                    height: 200,
                    width: 500,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstIn),
                    
                  ),

                  Text('Update Availability', style: TextStyle(fontSize:30, fontWeight: FontWeight.bold)),
                  
                  ]
                ),
              
              ),
            ),

            SizedBox(height: 50,)



          
          ],
        ),
      ),
    );
  }
}