import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/data.dart';
import 'package:http/http.dart' as http;
import 'package:add_2_calendar/add_2_calendar.dart';

class ConfirmLecture extends StatefulWidget {
  const ConfirmLecture({super.key});
  @override
  State<ConfirmLecture> createState() => _ConfirmLectureState();
}

class _ConfirmLectureState extends State<ConfirmLecture> {
  bool isLoading = true;
  bool _alreadyLoaded = false;
  List<consults> scheduled = [];
  List<consults> pending = [];
  List<consults> overall = [];
  Map<String, dynamic>? userData;
  String? roleFound;
  String? specDocID;
  Map<String, Uint8List?> studentImages = {};
  final TextEditingController rejectReason = TextEditingController();
  final TextEditingController location = TextEditingController();

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
        userData = data;
        userData!['role'] = roleFound;
      }
      await consultService.getAllConsults(roleFound.toString(), data!['name'].toString());
      scheduled = List.from(consultService.scheduled);
      pending = List.from(consultService.pending);
      overall.clear();
      overall.addAll(pending);
      overall.addAll(scheduled);
      for (var consult in overall) {
        await _loadStudentImage(consult.student);
      }
      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading consults: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> getId(int code) async {
    final query = await FirebaseFirestore.instance
        .collection('consults')
        .where('consult_code', isEqualTo: code)
        .limit(1)
        .get();
    specDocID = query.docs.first.id;
  }

  Future<void> completeConsult(int code) async {
    final query = await FirebaseFirestore.instance
        .collection('consults')
        .where('consult_code', isEqualTo: code)
        .limit(1)
        .get();
    if (query.docs.isEmpty) throw Exception('Consult not found');
    await query.docs.first.reference.update({'status': 'completed'});
  }

  Future<void> sendRejection(String documentID, String chosenStudent, int code, String module, String lecturer) async {
    final query = await FirebaseFirestore.instance.collection('students').where('name', isEqualTo: chosenStudent).limit(1).get();
    final data = query.docs.first.data();
    final id = query.docs.first.id;
    final url = Uri.parse('https://triaryl-thi-unobliged.ngrok-free.dev/rejectnotif');
    await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({
      'token': data['fcmTokens'],
      'docID': id,
      'role': 'students',
      'moduleName': module,
      'l_name': lecturer
    }));
    await FirebaseFirestore.instance.collection('consults').doc(documentID).update({
      'rej_reason': rejectReason.text,
      'status': "rejected",
    });
    setState(() {
      overall.removeWhere((item) => item.code == code);
      pending.removeWhere((item) => item.code == code);
    });
  }

  Future<void> sendAccept(String documentID, String chosenStudent, int code, String loc, String timeslot, String module, String student, String date, String lecturer) async {
    final studentQuery = await FirebaseFirestore.instance.collection('students').where('name', isEqualTo: chosenStudent).limit(1).get();
    final studentData = studentQuery.docs.first.data();
    final studentId = studentQuery.docs.first.id;
    final lecturerQuery = await FirebaseFirestore.instance.collection('lecturers').where('name', isEqualTo: lecturer).limit(1).get();
    final lecturerId = lecturerQuery.docs.first.id;
    final url = Uri.parse('https://triaryl-thi-unobliged.ngrok-free.dev/acceptnotif');
    await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({
      'token': studentData['fcmTokens'],
      'docID': lecturerId,
      'role': 'lecturers',
      'moduleName': module
    }));
    await FirebaseFirestore.instance.collection('consults').doc(documentID).update({'status': "scheduled", 'location': loc});
    final lecturerUid = FirebaseAuth.instance.currentUser?.uid;
    if (lecturerUid != null) {
      final lecturerDocRef = FirebaseFirestore.instance.collection('lecturers').doc(lecturerUid);
      final lecturerDoc = await lecturerDocRef.get();
      if (lecturerDoc.exists) {
        List<dynamic> availability = lecturerDoc.data()?['availability'] ?? [];
        int index = availability.indexWhere((day) => day['date'] == date);
        if (index >= 0) {
          List<String> timeslots = List<String>.from(availability[index]['timeslots'] ?? []);
          timeslots.remove(timeslot);
          availability[index]['timeslots'] = timeslots;
        }
        await lecturerDocRef.update({'availability': availability});
      }
    }
    final pendingQuery = await FirebaseFirestore.instance.collection('consults').where('status', isEqualTo: 'pending').get();
    for (var docSnap in pendingQuery.docs) {
      final data = docSnap.data();
      if (data['student'] == student || data['date'] != date || data['timeslot'] != timeslot || docSnap.id == documentID) continue;
      await docSnap.reference.update({'status': 'rejected', 'rej_reason': 'Timeslot already booked'});
      final conflictStudentQuery = await FirebaseFirestore.instance.collection('students').where('name', isEqualTo: data['student']).limit(1).get();
      if (conflictStudentQuery.docs.isNotEmpty) {
        final conflictData = conflictStudentQuery.docs.first.data();
        final notifUrl = Uri.parse('https://triaryl-thi-unobliged.ngrok-free.dev/rejectnotif');
        await http.post(notifUrl, headers: {"Content-Type": "application/json"}, body: jsonEncode({
          'token': conflictData['fcmTokens'],
          'docID': conflictStudentQuery.docs.first.id,
          'role': 'students',
          'moduleName': data['module'],
          'l_name': lecturer
        }));
      }
    }
    final times = timeslot.split('-');
    final startTime = DateTime.parse("$date ${times[0]}:00");
    final endTime = DateTime.parse("$date ${times[1]}:00");
    final Event event = Event(
      title: "$module consultation with $student",
      description: 'Consultation with Lecturer',
      location: 'Singapore Polytechnic, $loc',
      startDate: startTime,
      endDate: endTime,
      iosParams: IOSParams(reminder: Duration(minutes: 30)),
    );
    Add2Calendar.addEvent2Cal(event);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/reload');
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
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (overall.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Image.asset('assets/img/sp_logo.png', height: 40, fit: BoxFit.contain),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacementNamed(context, '/HomePage')),
          shape: const Border(bottom: BorderSide(color: Color.fromARGB(255, 195, 195, 195), width: 2)),
        ),
        body: const Center(child: Text('No pending or scheduled consultations', style: TextStyle(fontSize: 18))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset('assets/img/sp_logo.png', height: 40, fit: BoxFit.contain),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacementNamed(context, '/HomePage')),
        shape: const Border(bottom: BorderSide(color: Color.fromARGB(255, 195, 195, 195), width: 2)),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Requested / Scheduled Consultations', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: overall.length,
                itemBuilder: (context, index) {
                  final consult = overall[index];
                  Color bgColor = consult.status == 'scheduled' ? const Color.fromARGB(255, 255, 251, 146) : const Color.fromARGB(255, 255, 146, 146);
                  IconData icon = consult.status == 'scheduled' ? Icons.calendar_month : Icons.schedule;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: bgColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Text(consult.mod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(width: 10), Icon(icon)]),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                _buildAvatar(consult.student),
                                const SizedBox(height: 10),
                                Text(consult.student, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                                          Text(consult.code.toString())
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
                        if (consult.status == 'pending')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text('Confirm', style: TextStyle(fontSize: 20)),
                                        content: const Text('Enter location/link to consult', style: TextStyle(fontSize: 16)),
                                        actions: [
                                          Column(
                                            children: [
                                              TextField(controller: location, decoration: const InputDecoration(labelText: 'Location/Meeting Link', border: OutlineInputBorder())),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  MaterialButton(
                                                      child: const Text('Confirm'),
                                                      onPressed: () async {
                                                        if (location.text.trim().isEmpty) {
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Please enter location before proceeding.')));
                                                        } else {
                                                          Navigator.of(context).pop();
                                                          await getId(consult.code);
                                                          sendAccept(specDocID.toString(), consult.student, consult.code, location.text, consult.timeslot, consult.mod, consult.student, consult.date, consult.lecturer);
                                                        }
                                                      }),
                                                  MaterialButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop())
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 100),
                              FilledButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text('Confirm', style: TextStyle(fontSize: 20)),
                                        content: const Text('Add a Reason for Rejection (Optional)', style: TextStyle(fontSize: 16)),
                                        actions: [
                                          Column(
                                            children: [
                                              TextField(controller: rejectReason, decoration: const InputDecoration(labelText: 'Reason (Optional)', border: OutlineInputBorder())),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  MaterialButton(child: const Text('Confirm'), onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    await getId(consult.code);
                                                    sendRejection(specDocID.toString(), consult.student, consult.code, consult.mod, consult.lecturer);
                                                  }),
                                                  MaterialButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop())
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
                        else if (consult.status == 'scheduled')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton(
                                onPressed: () { Navigator.pushNamed(context, '/newNotes', arguments: {'role': 'lecturers', 'c_code': consult.code, 'name': consult.lecturer, 'notes': consult.lectureNotes}); },
                                child: const Text('Consultation Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 40),
                              FilledButton(
                                onPressed: () async { await completeConsult(consult.code); Navigator.pushNamed(context, '/reload'); },
                                child: const Text('Complete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
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
