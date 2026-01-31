import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/data.dart';

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

  @override
  void initState() {
    super.initState();
    _loadConsultsOnce();
  }

  Future<void> _loadConsultsOnce() async {
    if (_alreadyLoaded) return; // 🔹 Prevent double call
    _alreadyLoaded = true;

    // 🔹 Call service
    await consultService.getAllConsults();

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
      return const Scaffold(
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
                                  Text(consult.dates.isNotEmpty
                                      ? consult.dates.join('/')
                                      : 'No date'),
                                  const SizedBox(height: 8),
                                  const Text('Time',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(consult.timeslot.isNotEmpty
                                      ? consult.timeslot
                                      : 'No timeslot'),
                                  const SizedBox(height: 8),
                                  const Text('Location',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(consult.location.isNotEmpty
                                      ? consult.location
                                      : 'No location'),
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

