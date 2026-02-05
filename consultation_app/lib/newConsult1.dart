import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/data.dart';

class Newconsult1 extends StatefulWidget {
  const Newconsult1({super.key});

  @override
  State<Newconsult1> createState() => _Newconsult1State();
}

class _Newconsult1State extends State<Newconsult1> {
  String? _selectedModule;
  String? _selectedMode;
  String? _selectedLecturer;

  final TextEditingController _preController = TextEditingController();

  List<String> lecturers = [];
  List<Module> modules = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    await studentProfile_Service.getAllStudents();
    final user = FirebaseAuth.instance.currentUser;
    int index = studentProfile_Service.z.indexWhere((student) => student.uid == user?.uid);
    final profile = studentProfile_Service.getProfileAt(index);

    setState(() {
      lecturers = profile?.lecturers ?? [];
      modules = profile?.mods ?? [];
      isLoading = false;
    });
  }

  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'phone_android':
        return Icons.phone_android;
      case 'memory':
        return Icons.memory;
      case 'desktop_windows':
        return Icons.desktop_windows;
      case 'functions':
        return Icons.functions;
      case 'groups':
        return Icons.groups;
      case 'videocam':
        return Icons.videocam;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pushReplacementNamed(context, '/HomePage'),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          'assets/img/sp_logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 195, 195, 195),
            width: 2,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Consultation',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'Module Name / Code',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    modules.isEmpty
                        ? const Text(
                            'No modules available',
                            style: TextStyle(color: Colors.grey),
                          )
                        : Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: modules.map((module) {
                              return _OptionCard(
                                label: module.modCode,
                                tint: const Color(0xFFF3E9F5),
                                icon: getIconFromString(module.modIcon),
                                selected: _selectedModule == module.modCode,
                                onTap: () {
                                  setState(() {
                                    _selectedModule = module.modCode;
                                    lecturers = module.lectureSelect;
                                    _selectedLecturer = null;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                    const SizedBox(height: 24),

                    const Text(
                      'Lecturer Name',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLecturer,
                      decoration: InputDecoration(
                        hintText: 'Select lecturer',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: lecturers.map((lecturer) {
                        return DropdownMenuItem<String>(
                          value: lecturer,
                          child: Text(lecturer),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLecturer = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Preferred Mode of Consultation',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _OptionCard(
                            label: 'Physical',
                            tint: const Color(0xFFE9F3F6),
                            icon: Icons.groups,
                            height: 64,
                            selected: _selectedMode == 'Physical',
                            onTap: () {
                              setState(() {
                                _selectedMode = 'Physical';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _OptionCard(
                            label: 'Online',
                            tint: const Color(0xFFF7E7DC),
                            icon: Icons.videocam,
                            height: 64,
                            selected: _selectedMode == 'Online',
                            onTap: () {
                              setState(() {
                                _selectedMode = 'Online';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Pre-Consult Questions (Optional)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 5,
                      controller: _preController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedModule == null ||
                                _selectedMode == null ||
                                _selectedLecturer == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                      'Please fill in all required options.'),
                                ),
                              );
                              return;
                            }
                            if (_preController.text.trim().isNotEmpty) {
                              print(_preController.text);
                              Navigator.pushReplacementNamed(context, '/newConsult2', arguments: {'student_notes': _preController.text, 'selectedLecturer': _selectedLecturer.toString(), 'selectedModule': _selectedModule.toString(), 'selectedMode': _selectedMode.toString()});
                            } else {
                              Navigator.pushReplacementNamed(context, '/newConsult2', arguments: {'student_notes': "", 'selectedLecturer': _selectedLecturer.toString(), 'selectedModule': _selectedModule.toString(), 'selectedMode': _selectedMode.toString()});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0443E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Proceed',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.tint,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.height = 72,
  });

  final String label;
  final Color tint;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? const Color(0xFFE0443E) : const Color(0xFFD6D6D6);
    final textColor =
        selected ? const Color(0xFF1F1F1F) : const Color(0xFF424242);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
