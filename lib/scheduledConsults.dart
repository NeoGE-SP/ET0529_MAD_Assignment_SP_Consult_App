import 'package:flutter/material.dart';
import 'package:mad_assignment_sp_consult_booking/data.dart';
import 'package:mad_assignment_sp_consult_booking/newnotes.dart';

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
  List<consults> overall = [];

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
      scheduled = List.from(consultService.scheduled);
      pending = List.from(consultService.pending);
      
      for(int i=0;i<pending.length;i++){
        overall.add(pending[i]);
      }

      for (int i=0;i<scheduled.length;i++){
        overall.add(scheduled[i]);
      }

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
    if (overall.isEmpty) {
      return const Scaffold(
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
              'Consultation History',
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NewNotesPage(),
                                  ),
                                );
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  onPressed: () {
                                    // TODO: Show consultation notes
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
                                  onPressed: () {
                                    // TODO: Show consultation notes
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
