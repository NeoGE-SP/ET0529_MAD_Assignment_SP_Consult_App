import 'package:flutter/material.dart';
import 'data.dart';

class LectureProfile extends StatefulWidget {
  const LectureProfile({super.key});

  @override
  State<LectureProfile> createState() => _LectureProfileState();
}

class _LectureProfileState extends State<LectureProfile> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    await LectureProfileService.getAllLecturers();
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
    if (LectureProfileService.lecturers.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No lecturer profile found',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // ✅ SAFE: data exists
    final lecturer = LectureProfileService.lecturers[0];

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
                  _infoRow(Icons.person, 'Name', lecturer.name),
                  _infoRow(Icons.badge, 'Staff ID', lecturer.staffID),
                  _infoRow(Icons.email, 'Email', lecturer.email),

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

