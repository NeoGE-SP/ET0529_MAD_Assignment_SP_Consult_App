import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LectureHistoryPage extends StatefulWidget {
  const LectureHistoryPage({super.key});

  @override
  State<LectureHistoryPage> createState() => _LectureHistoryPageState();
}

class _LectureHistoryPageState extends State<LectureHistoryPage> {
  // ✅ Local instance variables for this page
  bool isLoading = true;
  bool _alreadyLoaded = false; // 🔹 Prevent double fetch
  List<consults> completed = [];
  Map<String, dynamic>? userData;
  String? roleFound;

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
    await consultService.getAllConsults(roleFound.toString(), data!['name'].toString());

    // 🔹 Copy completed consults to local instance variable
    setState(() {
      completed = List.from(consultService.completed);
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
    if (completed.isEmpty) {
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
        body: Center(
          child: Text(
            'No completed consultations yet',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // ✅ Data exists
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultation History',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: completed.length,
                itemBuilder: (context, index) {
                  final consult = completed[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 146, 255, 164),
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
                            const Icon(Icons.check_circle),
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
                                  consult.student,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

