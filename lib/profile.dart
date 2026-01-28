import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const Text(
              'My Profile', 
              style: TextStyle(fontSize:30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20,),
            
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color.fromARGB(255, 214, 214, 214),
              child: Image.asset('assets/img/sp_logo.png'), //Retrieve from firebase
            ),

            SizedBox(height: 20,),

            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: const Color.fromARGB(255, 255, 239, 192)
              ),
              child: Text('Edit Profile Picture', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              onPressed: () {
                print("Edit Profile Picture");
              },
            ),

            SizedBox(height: 20,),

            Container(
              padding: EdgeInsets.all(15),
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 255, 153, 146),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 10,),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Chew Kai Mark', style: TextStyle(fontSize: 15),) //Retrieve from firebase
                      ],)
                    ],
                  ),

                  SizedBox(height: 8,),

                  Row(
                    children: [
                      Icon(Icons.badge),
                      SizedBox(width: 10,),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Adm. No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('P2401234', style: TextStyle(fontSize: 15),) //Retrieve from firebase
                      ],)
                    ],
                  ),

                  SizedBox(height: 8,),

                  Row(
                    children: [
                      Icon(Icons.school),
                      SizedBox(width: 10,),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('DCPE/FT/2A/01', style: TextStyle(fontSize: 15),) //Retrieve from firebase
                      ],)
                    ],
                  ),

                  SizedBox(height: 8,),

                  Row(
                    children: [
                      Icon(Icons.email),
                      SizedBox(width: 10,),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('mark@sp.edu.sg', style: TextStyle(fontSize: 15),) //Retrieve from firebase
                      ],)
                    ],
                  ),

                  SizedBox(height: 20,),

                  Row(children: [
                    Text('For more info, click ', style: TextStyle(fontStyle: FontStyle.italic),),
                    TextButton(onPressed: () {}, 
                    child: Text('here', style: 
                    TextStyle(color: const Color.fromARGB(255, 0, 86, 156), fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                    Text('to access SAS.')
                  ],)

                  //Text('For more info, click here to access SAS.', style: TextStyle(fontStyle: FontStyle.italic),)


                ],
              ),
            )



            

          ],
        ),
      ),
    );
  }
}