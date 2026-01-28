import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const Text(
              'Consultation History', 
              style: TextStyle(fontSize:30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20,),

            Container(
              padding: const EdgeInsets.all(15),
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 146, 255, 164),
              ),
              child: Column(
                children: [
                  Row(children: [
                    Text('ET0529 - Mobile Applications Development', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),//Retrieve from database
                    SizedBox(width: 15,),
                    Icon(Icons.check_circle),
                    ],),
                  SizedBox(height: 8,),
                  Row(children: [
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                        child: Image.asset('assets/img/sp_logo.png'), //Retrieve from firebase
                      ),
                      SizedBox(height: 10),
                      Text('Wang Wei', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],),

                    SizedBox(width: 15),

                    Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('9 Janurary 2026', style: TextStyle(fontSize: 15),), //Retrieve from firebase

                      SizedBox(height: 8,),

                      Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('11:00 - 12:00', style: TextStyle(fontSize: 15),), //Retrieve from firebase

                      SizedBox(height: 8),

                      Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Online', style: TextStyle(fontSize: 15),), //Retrieve from firebase

                      SizedBox(height: 8,),
                      

                    ],),

                    
                  ],),


                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text('Consultation Notes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    onPressed: () {
                      print("Edit Profile Picture");
                    },
                  ),
                  
                  ]),

                  
                  )
              

          ],
          
        ),
      ),
    );
  }
}