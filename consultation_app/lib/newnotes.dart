import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class NewNotesPage extends StatefulWidget {
  const NewNotesPage({super.key});

  @override
  State<NewNotesPage> createState() => _NewNotesPageState();
}

class _NewNotesPageState extends State<NewNotesPage> {
  final TextEditingController _studentController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastRecognized = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _studentController.dispose();
    _lecturerController.dispose();
    _speech.stop();
    super.dispose();
  }

  TextEditingController _activeController(String role) {
    return role == 'students'
        ? _studentController
        : _lecturerController;
  }

  void _appendSpeech(String role, String spokenText) {
    if (spokenText.trim().isEmpty) return;
    if (spokenText == _lastRecognized) return; 

    _lastRecognized = spokenText;

    final controller = _activeController(role);

    final formatted = _applyBasicPunctuation(spokenText);

    final newText = controller.text.isEmpty
        ? formatted
        : '${controller.text} $formatted';

    controller.text = newText;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  String _applyBasicPunctuation(String text) {
    var t = text.trim();

    if (t.endsWith(' period')) {
      t = t.replaceFirst(RegExp(r' period$'), '.');
    } else if (t.endsWith(' comma')) {
      t = t.replaceFirst(RegExp(r' comma$'), ',');
    } else if (t.endsWith(' question mark')) {
      t = t.replaceFirst(RegExp(r' question mark$'), '?');
    }

    return t;
  }

  Future<void> _toggleListening(String role) async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for speech input.'),
          ),
        );
        return;
      }
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        setState(() => _isListening = false);
      },
    );

    if (!available) return;

    _lastRecognized = '';
    setState(() => _isListening = true);

    await _speech.listen(
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        _appendSpeech(role, result.recognizedWords);
      },
    );
  }

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
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/scheduleStudent');
    } else {
      await docRef.update({
        'lecturer_notes': _lecturerController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/scheduleLecture');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final int code = args['c_code'];
    final String role = args['role'];
    final String notes = args['notes'];
    final String name = args['name'];

    _activeController(role).text = notes.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Image.asset('assets/img/sp_logo.png', height: 40),
              const SizedBox(height: 8),
              Container(height: 1, color: const Color(0xFFD8D0DB)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 26),
                      onPressed: () => Navigator.of(context).maybePop(),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: NotesCard(
                  title:
                      role == 'students' ? 'Students Notes' : 'Lecturers Notes',
                  name: name,
                  controller: _activeController(role),
                  isListening: _isListening,
                  onMicPressed: () => _toggleListening(role),
                  backgroundColor: role == 'students'
                      ? const Color(0xFFFFF1DC)
                      : const Color.fromARGB(255, 255, 202, 122),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    _saveNotes(consultCode: code, role: role),
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.blue),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesCard extends StatelessWidget {
  final String title;
  final String name;
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onMicPressed;
  final Color backgroundColor;

  const NotesCard({
    super.key,
    required this.title,
    required this.name,
    required this.controller,
    required this.isListening,
    required this.onMicPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isListening
                ? Colors.red.withOpacity(0.35)
                : Colors.black.withOpacity(0.08),
            blurRadius: isListening ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFF2A1F18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF2A1F18))),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    color: isListening ? Colors.red : Colors.black,
                  ),
                  onPressed: onMicPressed,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: null,
              minLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type or speak your notes here...',
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
