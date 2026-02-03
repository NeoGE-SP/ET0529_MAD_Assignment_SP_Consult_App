import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _studentController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();

  Future<void> _saveNotes({
    required int consultCode,
    required String role,
  }) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('consults')
        .where('consult_code', isEqualTo: consultCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Consult not found');
    }

    final docRef = querySnapshot.docs.first.reference;

    if (role == 'students') {
      await docRef.update({
        'student_notes': _studentController.text.trim(),
      });
      if(!mounted) return;
      Navigator.pushReplacementNamed(context, '/HomePage', arguments: 1);
    } else {
      await docRef.update({
        'lecturer_notes': _lecturerController.text.trim(),
      });
      if(!mounted) return;
      Navigator.pushReplacementNamed(context, '/HomePage', arguments: 1);
    }
  }

  @override
  void dispose() {
    _studentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    int code = args['c_code'];
    String role = args['role'];
    String s_notes = args['student_notes'];
    String l_notes = args['lecturer_notes'];

    if (role == 'students') {
    _studentController.text = s_notes.trim();
    _lecturerController.text = l_notes.trim();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Image.asset(
                'assets/img/sp_logo.png',
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: const Color(0xFFD8D0DB),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 26),
                      onPressed: () {Navigator.pushReplacementNamed(context, '/HomePage', arguments: 1);},
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Consultation Notes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: _StudentNotesCard(
                    controller: _studentController,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: _ReadLecturerNotesCard(
                    controller: _lecturerController,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushNamed(context, '/aisummary', arguments: {'l_notes': l_notes.trim(), 's_notes': s_notes.trim()});
                }, 
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                child: Text(
                  "Get AI Summary",
                  style: TextStyle(color: Colors.white),
                )
              ),
              SizedBox(height: 8,),
              ElevatedButton(
                onPressed: () async {
                  await _saveNotes(consultCode: code, role: role);
                }, 
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
  else {
    _lecturerController.text = l_notes.trim();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Image.asset(
                'assets/img/sp_logo.png',
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: const Color(0xFFD8D0DB),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 26),
                      onPressed: () {Navigator.pushReplacementNamed(context, '/HomePage', arguments: 1);}
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Consultation Notes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: _LecturerNotesCard(
                    controller: _lecturerController,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await _saveNotes(consultCode: code, role: role);
                }, 
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
  }
}

class _StudentNotesCard extends StatelessWidget {
  final TextEditingController controller;

  const _StudentNotesCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String name = args['student_name'];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DC),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2A1F18),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2A1F18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: null,
              minLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type your notes here...',
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: Color(0xFF2A1F18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _LecturerNotesCard extends StatelessWidget {
  final TextEditingController controller;

  const _LecturerNotesCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String name = args['lecturer_name'];

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 202, 122),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2A1F18),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lecturers Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2A1F18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: null,
              minLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type your notes here...',
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: Color(0xFF2A1F18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadLecturerNotesCard extends StatelessWidget {
  final TextEditingController controller;

  const _ReadLecturerNotesCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String name = args['lecturer_name'];

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 202, 122),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2A1F18),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lecturers Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2A1F18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              readOnly: true,
              maxLines: null,
              minLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type your notes here...',
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: Color(0xFF2A1F18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
