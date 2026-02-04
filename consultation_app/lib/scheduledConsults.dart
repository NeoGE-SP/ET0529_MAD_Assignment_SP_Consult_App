import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/data.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class ConfirmStudent extends StatefulWidget {
  const ConfirmStudent({super.key});

  @override
  State<ConfirmStudent> createState() => _ConfirmStudentState();
}

class _ConfirmStudentState extends State<ConfirmStudent> {
  bool isLoading = true;
  bool _alreadyLoaded = false;

  List<consults> scheduled = [];
  List<consults> pending = [];
  List<consults> rejected = [];
  List<consults> overall = [];

  Map<String, dynamic>? userData;
  String? roleFound;
  String? specDocID;

  Map<String, Uint8List?> lecturerImages = {};

  @override
  void initState() {
    super.initState();
    _loadConsultsOnce();
  }

  Future<void> _loadLecturerImage(String lecturerName) async {
    if (lecturerImages.containsKey(lecturerName)) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('lecturers')
          .where('name', isEqualTo: lecturerName)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();

        if (data['profileImageBase64'] != null &&
            data['profileImageBase64'].toString().isNotEmpty) {
          final bytes = base64Decode(data['profileImageBase64']);

          if (!mounted) return;
          setState(() {
            lecturerImages[lecturerName] = bytes;
          });
        } else {
          lecturerImages[lecturerName] = null;
        }
      }
    } catch (e) {
      print("Error loading lecturer image: $e");
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
        final doc = await FirebaseFirestore.instance
            .collection(col)
            .doc(user.uid)
            .get();

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

      await consultService.getAllConsults(
          roleFound.toString(), data!['name'].toString());

      scheduled = List.from(consultService.scheduled);
      pending = List.from(consultService.pending);
      rejected = List.from(consultService.rejected);

      overall.clear();
      overall.addAll(pending);
      overall.addAll(scheduled);
      overall.addAll(rejected);

      for (var consult in overall) {
        await _loadLecturerImage(consult.lecturer);
      }

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading consults: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> markCalendar(
      String location,
      String timeslot,
      String module,
      String student,
      String date,
      String lecturer) async {
    final times = timeslot.split('-');

    final startTime = DateTime.parse("$date ${times[0]}:00");
    final endTime = DateTime.parse("$date ${times[1]}:00");

    final Event event = Event(
      title: "$module consultation with $lecturer",
      description: 'Consultation with Lecturer',
      location: location,
      startDate: startTime,
      endDate: endTime,
      iosParams: IOSParams(reminder: Duration(minutes: 30)),
    );

    Add2Calendar.addEvent2Cal(event);
  }

  Future<void> cancelConsult(int code) async {
    final query = await FirebaseFirestore.instance
        .collection('consults')
        .where('consult_code', isEqualTo: code)
        .limit(1)
        .get();

    final id = query.docs.first.id;

    await FirebaseFirestore.instance
        .collection('consults')
        .doc(id)
        .delete();

    setState(() {
      overall.removeWhere((item) => item.code == code);
      pending.removeWhere((item) => item.code == code);
      rejected.removeWhere((item) => item.code == code);
    });
  }

  Future<void> getId(int code) async {
    final query = await FirebaseFirestore.instance
        .collection('consults')
        .where('consult_code', isEqualTo: code)
        .limit(1)
        .get();

    specDocID = query.docs.first.id;
  }

  Widget _buildAvatar(String lecturerName) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: const Color.fromARGB(255, 214, 214, 214),
      backgroundImage: lecturerImages[lecturerName] != null
          ? MemoryImage(lecturerImages[lecturerName]!)
          : null,
      child: lecturerImages[lecturerName] == null
          ? const Icon(Icons.person, size: 40)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (overall.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text('No pending or scheduled consultations'),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
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

                  return _buildConsultCard(consult);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultCard(consults consult) {
    Color bgColor;
    IconData icon;

    if (consult.status == 'scheduled') {
      bgColor = const Color.fromARGB(255, 255, 251, 146);
      icon = Icons.calendar_month;
    } else if (consult.status == 'rejected') {
      bgColor = const Color.fromARGB(255, 255, 146, 146);
      icon = Icons.close;
    } else {
      bgColor = const Color.fromARGB(255, 255, 146, 146);
      icon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                consult.mod,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 10),
              Icon(icon),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                children: [
                  _buildAvatar(consult.lecturer),
                  const SizedBox(height: 10),
                  Text(
                    consult.lecturer,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _info('Date', consult.date),
                        if (consult.status == 'rejected') ...[
                          SizedBox(width: 15,),
                          Text("|"),
                          SizedBox(width: 15,),
                          SizedBox(
                            width: 130,
                            child: _info('Reason', consult.reason)
                          )
                        ]
                      ]
                    ),
                    _info('Time', consult.timeslot),
                    _info('Location', consult.location),
                    _info('Consult Code', consult.code.toString()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildButtons(consult),
        ],
      ),
    );
  }

  Widget _buildButtons(consults consult) {
    if (consult.status == 'scheduled') {
      return Row(
        children: [
          FilledButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/newNotes', arguments: {
                'role': 'students',
                'c_code': consult.code,
                'name': consult.student,
                'notes': consult.studentNotes
              });
            },
            child: const Text('Consultation Notes'),
          ),
          const SizedBox(width: 20),
          FilledButton(
            onPressed: () {
              markCalendar(consult.location, consult.timeslot, consult.mod,
                  consult.student, consult.date, consult.lecturer);
            },
            child: const Text('Add to Calendar'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          onPressed: () => cancelConsult(consult.code),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 100),
        FilledButton(
          onPressed: () async {
            await getId(consult.code);
            Navigator.pushReplacementNamed(context, '/reschedConsult', arguments: {
              'docID': specDocID,
              'selectedLecturer': consult.lecturer,
              'module': consult.mod
            });
          },
          child: const Text('Reschedule'),
        ),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value.isNotEmpty ? value : 'N/A'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Image.asset('assets/img/sp_logo.png', height: 40),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () =>
            Navigator.pushReplacementNamed(context, '/HomePage'),
      ),
      shape: const Border(
        bottom: BorderSide(
          color: Color.fromARGB(255, 195, 195, 195),
          width: 2,
        ),
      ),
    );
  }
}
