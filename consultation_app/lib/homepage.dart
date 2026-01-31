import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mad_assignment_sp_consult_booking/notification_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? roleFound;
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
        userData!['role'] = roleFound; // store the role as well
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
    
    Future<void> signOut() async {
      NotificationService notificationService = NotificationService();
      String fcmToken = await notificationService.getFcmToken();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection(roleFound.toString()) // or "lecturers", depending on role
          .doc(user.uid)
          .update({
            "fcmTokens": FieldValue.arrayRemove([fcmToken])
      });
      await FirebaseAuth.instance.signOut();
    }

    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          
          children: [
            const Padding(padding: EdgeInsetsGeometry.all(10)),
            const Text(
              'Welcome Mark!', //add variable here for name from firebase
              style: TextStyle(fontSize:30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5,),

            const Text('What would you like to do today?', style: TextStyle(fontSize: 15),),
            ElevatedButton(
              onPressed: () async {
                await signOut();
                // navigation happens after signOut finishes
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("Sign Out"),
            ),

            const SizedBox(height: 30,),


             Expanded(
              child: InkWell(
                onTap: () {
                 // Navigator.push(context, MaterialPageRoute(builder: builder))
                  Navigator.pushNamed(context, '/newConsult1');

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

                  Text('Book a new consultation', style: TextStyle(fontSize:30, fontWeight: FontWeight.bold)),
                  
                  ]
                ),
              
              ),
            ),

            SizedBox(height: 20,),           

            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/scheduleStudent');
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

                  Text('View scheduled consultations', style: TextStyle(fontSize:30, fontWeight: FontWeight.bold)),
                  
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