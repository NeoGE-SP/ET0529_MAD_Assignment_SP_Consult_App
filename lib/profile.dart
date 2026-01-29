import 'package:flutter/material.dart';
import 'data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    await studentProfile_Service.getAllStudents();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 Loading state
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 📭 Empty state
    if (studentProfile_Service.z.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No student profile found',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // ✅ SAFE: data exists
    final student = studentProfile_Service.z[0];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(255, 214, 214, 214),
              child: Icon(Icons.person, size: 50),
            ),

            const SizedBox(height: 20),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 239, 192),
              ),
              onPressed: () {
                // future: change profile picture
              },
              child: const Text(
                'Edit Profile Picture',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 255, 153, 146),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.person, 'Name', student.name),
                  _infoRow(Icons.badge, 'Adm. No.', student.adm),
                  _infoRow(Icons.school, 'Class', student.classNo),
                  _infoRow(Icons.email, 'Email', student.email),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Text(
                        'For more info, click ',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'here',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 86, 156),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text('to access SAS.'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small helper widget to reduce repetition
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'data.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//     @override
//     void initState() {
//       super.initState();
//       loadProfile();
//     }

//   Future<void> loadProfile() async {
//     await studentProfile_Service.getAllStudents();
//     setState(() {
//     });
//   }

//   final student = studentProfile_Service.z[0];

  

//   @override
//   Widget build(BuildContext context) {

  
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           children: [
//             const Text(
//               'My Profile', 
//               style: TextStyle(fontSize:30, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 20,),
            
//             CircleAvatar(
//               radius: 50,
//               backgroundColor: const Color.fromARGB(255, 214, 214, 214),
//               child: Image.asset('assets/img/sp_logo.png'), //Retrieve from firebase
//             ),

//             SizedBox(height: 20,),

//             FilledButton(
//               style: FilledButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 backgroundColor: const Color.fromARGB(255, 255, 239, 192)
//               ),
//               child: Text('Edit Profile Picture', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
//               onPressed: () {
//                 print("Edit Profile Picture");
//               },
//             ),

//             SizedBox(height: 20,),

//             Container(
//               padding: EdgeInsets.all(15),
//               width: 350,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: const Color.fromARGB(255, 255, 153, 146),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.person),
//                       SizedBox(width: 10,),
//                       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                         Text(student.name, style: TextStyle(fontSize: 15),) //Retrieve from firebase
//                       ],)
//                     ],
//                   ),

//                   SizedBox(height: 8,),

//                   Row(
//                     children: [
//                       Icon(Icons.badge),
//                       SizedBox(width: 10,),
//                       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text('Adm. No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                         Text(student.adm, style: TextStyle(fontSize: 15),) //Retrieve from firebase
//                       ],)
//                     ],
//                   ),

//                   SizedBox(height: 8,),

//                   Row(
//                     children: [
//                       Icon(Icons.school),
//                       SizedBox(width: 10,),
//                       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text('Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                         Text(student.classNo, style: TextStyle(fontSize: 15),) //Retrieve from firebase
//                       ],)
//                     ],
//                   ),

//                   SizedBox(height: 8,),

//                   Row(
//                     children: [
//                       Icon(Icons.email),
//                       SizedBox(width: 10,),
//                       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                         Text(student.email, style: TextStyle(fontSize: 15),) //Retrieve from firebase
//                       ],)
//                     ],
//                   ),

//                   SizedBox(height: 20,),

//                   Row(children: [
//                     Text('For more info, click ', style: TextStyle(fontStyle: FontStyle.italic),),
//                     TextButton(onPressed: () {}, 
//                     child: Text('here', style: 
//                     TextStyle(color: const Color.fromARGB(255, 0, 86, 156), fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
//                     Text('to access SAS.')
//                   ],)

//                   //Text('For more info, click here to access SAS.', style: TextStyle(fontStyle: FontStyle.italic),)


//                 ],
//               ),
//             )



            

//           ],
//         ),
//       ),
//     );
//   }
// }