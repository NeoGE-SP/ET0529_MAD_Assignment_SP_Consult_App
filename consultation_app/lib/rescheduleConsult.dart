import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Rescheduleconsult extends StatefulWidget {
  const Rescheduleconsult({super.key});

  @override
  State<Rescheduleconsult> createState() => _RescheduleconsultState();
}

class _RescheduleconsultState extends State<Rescheduleconsult> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  String? _selectedTime;
  List<dynamic> _availableTimeslots = [];
  String? roleFound;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? _selectedMode;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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
      setState(() {
        userData = data;
        userData!['role'] = roleFound; 
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
  }
  
  

  void _updateTimeslotsForDate(DateTime date, String chosenLecturer) async {
    _selectedTime = null; 

    _availableTimeslots = [];
    _selectedDate = date;
    String dateInfo = _selectedDate!.toIso8601String().split('T')[0];

    final query = await FirebaseFirestore.instance
          .collection('lecturers')
          .where('name', isEqualTo: chosenLecturer)
          .limit(1)
          .get();
                  

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      print(data['availability']);
      print(dateInfo);
      print(data['availability'][0]['timeslots']);
      for(int i=0; i<(data['availability'] as List).length;i++){
          if (dateInfo == data['availability'][i]['date']){
            _availableTimeslots = (data['availability'][i]['timeslots']);
        }
      }

      setState(() {
        _availableTimeslots;
        print(_availableTimeslots);
      });
    }
  }

  Future<int> getNextConsultCode() async {
    final DocumentReference counterRef = FirebaseFirestore.instance.collection('metadata').doc('consults_stats');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(counterRef);

      if (!snapshot.exists) {
        throw Exception("Counter document does not exist!");
      }

      int newCode = (snapshot.get('last_code') ?? 0) + 1;

      transaction.update(counterRef, {'last_code': newCode});

      return newCode;
    });
  }

  Future<void> sendRequest(String documentID, 
    String chosenLecturer,
    String date,
    String timeslot,
    String module,
    String location) async {
      final query = await FirebaseFirestore.instance
            .collection('lecturers')
            .where('name', isEqualTo: chosenLecturer)
            .limit(1)
            .get();

      final url = Uri.parse('https://triaryl-thi-unobliged.ngrok-free.dev/requestnotif');

      final data = query.docs.first.data();
      
      final query2 = await FirebaseFirestore.instance
            .collection('students')
            .where('name', isEqualTo: userData!['name'])
            .limit(1)
            .get();

      final id = query2.docs.first.id;

      await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'token': data['fcmTokens'],
            'docID': id,
            'role': 'students',
            'moduleName': module,
          })
        );

      date = date.split(" ")[0];
      await FirebaseFirestore.instance
        .collection('consults')
        .doc(documentID)
        .update({
          'date': date,
          'timeslot': timeslot,
          'status': 'pending',
          'location': location,
          'rej_reason': "",
    });
      print("request sent lol");
}


  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String chosenLecturer = args['selectedLecturer'];
    String documentID = args['docID'];
    String getMod = args['module'];


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/scheduleStudent'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reschedule Consultation',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
            _CalendarCard(
              month: _focusedMonth,
              selectedDate: _selectedDate,
              onPrev: () {
                setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                });
              },
              onNext: () {
                setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                });
              },
              onSelectDate: (date) {
                setState(() {
                  _updateTimeslotsForDate(date, chosenLecturer);
                });
              },
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: _availableTimeslots.isEmpty
                  ? [
                      const Text(
                        'No available timeslots for this date.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : _availableTimeslots
                      .map(
                        (slot) => _TimeSlotButton(
                          label: slot,
                          selected: _selectedTime == slot,
                          onTap: () {
                            setState(() {
                              _selectedTime = slot;
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 240,
                height: 48,
                child: ElevatedButton(
                  onPressed: (_selectedDate != null && _selectedTime != null)
                      ? () async {
                          await sendRequest(documentID, chosenLecturer, _selectedDate.toString(), _selectedTime.toString(), getMod, _selectedMode.toString());
                          Navigator.pushReplacementNamed(context, '/scheduleStudent');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0443E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Rechedule Consultation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// --------------------- Widgets ---------------------


class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.selectedDate,
    required this.onPrev,
    required this.onNext,
    required this.onSelectDate,
  });

  final DateTime month;
  final DateTime? selectedDate;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final trailingEmpty = (7 - (totalCells % 7)) % 7;
    final monthLabel = _monthLabel(month);

    final tomorrow = DateTime.now().add(const Duration(days: 1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDBDBD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left),
                splashRadius: 18,
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekdayLabel('Mo'),
              _WeekdayLabel('Tu'),
              _WeekdayLabel('We'),
              _WeekdayLabel('Th'),
              _WeekdayLabel('Fr'),
              _WeekdayLabel('Sa'),
              _WeekdayLabel('Su'),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 0,
            runSpacing: 4,
            children: [

              for (int i = 0; i < leadingEmpty; i++) const _DayCell.empty(),

              for (int day = 1; day <= daysInMonth; day++)
                _DayCell(
                  day: day,
                  selected: _isSameDay(
                    selectedDate,
                    DateTime(month.year, month.month, day),
                  ),

                  onTap: DateTime(month.year, month.month, day)
                          .isBefore(DateTime(
                        tomorrow.year,
                        tomorrow.month,
                        tomorrow.day,
                      ))
                      ? null
                      : () => onSelectDate(
                            DateTime(month.year, month.month, day),
                          ),
                ),

              for (int i = 0; i < trailingEmpty; i++) const _DayCell.empty(),
            ],
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    this.day,
    this.selected = false,
    this.onTap,
  });

  const _DayCell.empty()
      : day = null,
        selected = false,
        onTap = null;

  final int? day;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox(width: 44, height: 36);

    final disabled = onTap == null;

    return SizedBox(
      width: 44,
      height: 36,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFE0443E)
                  : disabled
                      ? const Color(0xFFEDEDED)
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : disabled
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF616161),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeSlotButton extends StatelessWidget {
  const _TimeSlotButton({
    required this.label,
    required this.selected,
    this.onTap,
    this.disabled = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? const Color(0xFFE0443E)
        : disabled
            ? const Color(0xFFEDEDED)
            : Colors.white;
    final textColor = selected
        ? Colors.white
        : disabled
            ? const Color(0xFF9E9E9E)
            : const Color(0xFF212121);
    final borderColor =
        selected ? const Color(0xFFE0443E) : const Color(0xFFBDBDBD);

    return SizedBox(
      width: 160,
      height: 44,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
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
