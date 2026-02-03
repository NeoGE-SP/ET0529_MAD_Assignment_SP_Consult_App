import 'dart:convert';
import 'dart:typed_data';
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
  bool isLoading = true;
  bool _alreadyLoaded = false; 
  List<consults> completed = [];
  Map<String, dynamic>? userData;
  String? roleFound;
  Map<String, Uint8List?> studentImages = {};

  @override
  void initState() {
    super.initState();
    _loadConsultsOnce();
  }

  Future<void> _loadStudentImage(String studentName) async {
    if (studentImages.containsKey(studentName)) return;
    try {
      final query = await FirebaseFirestore.instance
          .collection('students')
          .where('name', isEqualTo: studentName)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (data['profileImageBase64'] != null && data['profileImageBase64'].toString().isNotEmpty) {
          final bytes = base64Decode(data['profileImageBase64']);
          if (!mounted) return;
          setState(() {
            studentImages[studentName] = bytes;
          });
        } else {
          studentImages[studentName] = null;
        }
      }
    } catch (e) {
      print("Error loading student image: $e");
    }
  }

  Future<void> _loadConsultsOnce() async {
    if (_alreadyLoaded) return; 
    _alreadyLoaded = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    Map<String, dynamic>? data;

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
      userData = data;
      userData!['role'] = roleFound;
    }

    await consultService.getAllConsults(roleFound.toString(), data!['name'].toString());
    completed = List.from(consultService.completed);

    for (var consult in completed) {
      await _loadStudentImage(consult.student);
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Widget _buildAvatar(String studentName) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: const Color.fromARGB(255, 214, 214, 214),
      backgroundImage: studentImages[studentName] != null ? MemoryImage(studentImages[studentName]!) : null,
      child: studentImages[studentName] == null ? const Icon(Icons.person, size: 40) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (completed.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'No completed consultations yet',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                _buildAvatar(consult.student),
                                const SizedBox(height: 10),
                                Text(
                                  consult.student,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(consult.date.isNotEmpty ? consult.date : 'No date'),
                                  const SizedBox(height: 8),
                                  const Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(consult.timeslot.isNotEmpty ? consult.timeslot : 'No timeslot'),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(consult.location.isNotEmpty ? consult.location : 'No location'),
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      const Text("|"),
                                      const SizedBox(width: 20),
                                      Column(
                                        children: [
                                          const Text('Consult Code', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(consult.code.toString()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.white),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/notes', arguments: {
                                'lecturer_name': consult.lecturer,
                                'lecturer_notes': consult.lectureNotes,
                                'student_name': consult.student,
                                'student_notes': consult.studentNotes,
                                'c_code': consult.code,
                                'role': 'lecturers'
                              });
                            },
                            child: const Text(
                              'Consultation Notes',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
