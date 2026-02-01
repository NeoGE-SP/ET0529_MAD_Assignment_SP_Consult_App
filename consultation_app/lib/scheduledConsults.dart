import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/data.dart';

class ConfirmStudent extends StatefulWidget {
  const ConfirmStudent({super.key});

  @override
  State<ConfirmStudent> createState() => _ConfirmStudentState();
}

class _ConfirmStudentState extends State<ConfirmStudent> {
 // ✅ Local instance variables for this page
  bool isLoading = true;
  bool _alreadyLoaded = false; // 🔹 Prevent double fetch
  List<consults> scheduled = [];
  List<consults> pending = [];
  List<consults> rejected = [];
  List<consults> overall = [];
  Map<String, dynamic>? userData;
  String? roleFound;
  String? specDocID;

  @override
  void initState() {
    super.initState();
    _loadConsultsOnce();
  }

  Future<void> _loadConsultsOnce() async {
    if (_alreadyLoaded) return; // 🔹 Prevent double call
    _alreadyLoaded = true;

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

    // 🔹 Call service
    print(data!['name'].toString());
    await consultService.getAllConsults(roleFound.toString(), data['name'].toString());

    // 🔹 Copy completed consults to local instance variable
    setState(() {
      scheduled = List.from(consultService.scheduled);
      pending = List.from(consultService.pending);
      rejected = List.from(consultService.rejected);
      
      for(int i=0;i<pending.length;i++){
        overall.add(pending[i]);
      }

      for (int i=0;i<scheduled.length;i++){
        overall.add(scheduled[i]);
      }

      for (int i=0;i<rejected.length;i++){
        overall.add(rejected[i]);
      }

      isLoading = false;
    });
  }

  Future<void> cancelConsult(int code) async {
    final query = await FirebaseFirestore.instance
          .collection('consults')
          .where('consult_code', isEqualTo: code)
          .limit(1)
          .get();

    String id = query.docs.first.id;
    print(id);

    await FirebaseFirestore.instance
      .collection('consults')
      .doc(id)
      .delete();

    setState(() {
      specDocID = id;
      overall.removeWhere((item) => item.code == code);
      pending.removeWhere((item) => item.code == code);
      rejected.removeWhere((item) => item.code == code);
    });

    print("Cancelled Consult Successfully");
  }

  Future<void> getId(int code) async {
    final query = await FirebaseFirestore.instance
          .collection('consults')
          .where('consult_code', isEqualTo: code)
          .limit(1)
          .get();

    String id = query.docs.first.id;
    print(id);

    setState(() {
      specDocID = id;
    });

    print("got id");
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
    if (overall.isEmpty) {
      return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset('assets/img/sp_logo.png', height: 40, fit: BoxFit.contain,),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/HomePage'),
        ),
        shape: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 195, 195, 195),
            width: 2,
          ),
        ),
      ),
      backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'No pending or scheduled consultations',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // ✅ Data exists
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset('assets/img/sp_logo.png', height: 40, fit: BoxFit.contain,),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/HomePage'),
        ),
        shape: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 195, 195, 195),
            width: 2,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scheduled / Pending Consultations',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: overall.length,
                itemBuilder: (context, index) {
                  final consult = overall[index];

                  if (consult.status=='scheduled'){
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        //color: const Color.fromARGB(255, 255, 146, 146),
                        color: const Color.fromARGB(255, 255, 251, 146),

                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                consult.mod,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.calendar_month),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                        Color.fromARGB(255, 214, 214, 214),
                                    child: Icon(Icons.person, size: 40),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    consult.lecturer,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(consult.date.isNotEmpty
                                        ? consult.date
                                        : 'No date'),
                                    const SizedBox(height: 8),
                                    const Text('Time',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(consult.timeslot.isNotEmpty
                                        ? consult.timeslot
                                        : 'No timeslot'),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      Column(children: [
                                        const Text('Location',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                      Text(consult.location.isNotEmpty
                                          ? consult.location
                                          : 'No location'),
                                      ],),
                                      const SizedBox(width: 20,),
                                      const Text("|"),
                                      const SizedBox(width: 20,),
                                      Column(children: [
                                        const Text('Consult Code',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                      Text(consult.code.toString())
                                      ],),
                                      ],),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: () {
                                // TODO: Show consultation notes
                              },
                              child: const Text(
                                'Consultation Notes',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (consult.status == "rejected") {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 255, 146, 146),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                consult.mod,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.close, color: Colors.black,),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                        Color.fromARGB(255, 214, 214, 214),
                                    child: Icon(Icons.person, size: 40),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    consult.lecturer,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Column(children: [
                                        const Text('Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(consult.date.isNotEmpty
                                        ? consult.date
                                        : 'No date'),
                                    const SizedBox(height: 8),
                                    const Text('Time',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(consult.timeslot.isNotEmpty
                                        ? consult.timeslot
                                        : 'No timeslot'),
                                      ],),
                                      const SizedBox(width: 20,),
                                      const Text("|"),
                                      const SizedBox(width: 20,),
                                      Column(children: [
                                        const Text('Reason',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                      Text(consult.reason.toString()),
                                      const SizedBox(height: 8,),
                                      const Text("_____")
                                      ],)

                                    ],),
                                    
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      Column(children: [
                                        const Text('Location',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                      Text(consult.location.isNotEmpty
                                          ? consult.location
                                          : 'No location'),
                                      ],),
                                      const SizedBox(width: 20,),
                                      const Text("|"),
                                      const SizedBox(width: 20,),
                                      Column(children: [
                                        const Text('Consult Code',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                      Text(consult.code.toString())
                                      ],),
                                      ],),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  onPressed: () {
                                    cancelConsult(consult.code);
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),

                                SizedBox(width: 100),


                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  onPressed: () async {
                                    await getId(consult.code);
                                    Navigator.pushNamed(context, '/reschedConsult', arguments: {'docID': specDocID.toString(), 'selectedLecturer' : consult.lecturer.toString()});
                                    //firebase func to update date ONLY
                                  },
                                  child: const Text(
                                    'Reschedule',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ]),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 255, 146, 146),

                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                consult.mod,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.schedule),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                        Color.fromARGB(255, 214, 214, 214),
                                    child: Icon(Icons.person, size: 40),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    consult.lecturer,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(consult.date.isNotEmpty
                                        ? consult.date
                                        : 'No date'),
                                    const SizedBox(height: 8),
                                    const Text('Time',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(consult.timeslot.isNotEmpty
                                        ? consult.timeslot
                                        : 'No timeslot'),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      Column(children: [
                                        const Text('Location',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                      Text(consult.location.isNotEmpty
                                          ? consult.location
                                          : 'No location'),
                                      ],),
                                      const SizedBox(width: 20,),
                                      const Text("|"),
                                      const SizedBox(width: 20,),
                                      Column(children: [
                                        const Text('Consult Code',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                      Text(consult.code.toString())
                                      ],),
                                      ],),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  onPressed: () {
                                    cancelConsult(consult.code);
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),

                                SizedBox(width: 100),


                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  onPressed: () async {
                                    await getId(consult.code);
                                    Navigator.pushNamed(context, '/reschedConsult', arguments: {'docID': specDocID, 'selectedLecturer' : consult.lecturer.toString()});
                                    //firebase func to update date ONLY
                                  },
                                  child: const Text(
                                    'Reschedule',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),


                            ]),
                        ],
                      ),
                    );
                  }

                  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
