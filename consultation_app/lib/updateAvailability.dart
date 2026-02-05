import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateAvailabilityPage extends StatefulWidget {
  const UpdateAvailabilityPage({super.key});

  @override
  State<UpdateAvailabilityPage> createState() => _UpdateAvailabilityPageState();
}

class _UpdateAvailabilityPageState extends State<UpdateAvailabilityPage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  List<String> _existingTimeslots = [];
  List<String> _newSelections = [];
  List<String> _removedSelections = [];
  List<String> _allTimeslots = [];

  final int startHour = 8;
  final int endHour = 18;
  String? lecturerUid;

  @override
  void initState() {
    super.initState();
    lecturerUid = FirebaseAuth.instance.currentUser?.uid;
    _generateAllTimeslots();
  }

  void _generateAllTimeslots() {
    _allTimeslots = [
      for (int i = startHour; i < endHour; i++)
        "${i.toString().padLeft(2, '0')}:00-${(i + 1).toString().padLeft(2, '0')}:00"
    ];
  }

  Future<void> _loadTimeslotsForDate(DateTime date) async {
    if (lecturerUid == null) return;

    final dateStr =
        "${date.year.toString().padLeft(4,'0')}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";

    final doc = await FirebaseFirestore.instance
        .collection('lecturers')
        .doc(lecturerUid)
        .get();

    List<dynamic> availability = doc.data()?['availability'] ?? [];

    List<String> existing = [];
    for (var day in availability) {
      if (day['date'] == dateStr) {
        existing = List<String>.from(day['timeslots'] ?? []);
        break;
      }
    }

    setState(() {
      _selectedDate = date;
      _existingTimeslots = existing;
      _newSelections = [];
      _removedSelections = [];
    });
  }

  void _toggleTimeslot(String slot) {
    setState(() {
      if (_existingTimeslots.contains(slot)) {
        if (_removedSelections.contains(slot)) {
          _removedSelections.remove(slot);
        } else {
          _removedSelections.add(slot);
        }
      } else {
        if (_newSelections.contains(slot)) {
          _newSelections.remove(slot);
        } else {
          _newSelections.add(slot);
        }
      }
    });
  }

  Future<void> _confirmChanges() async {
    if (_selectedDate == null || lecturerUid == null) return;

    final dateStr =
        "${_selectedDate!.year.toString().padLeft(4,'0')}-${_selectedDate!.month.toString().padLeft(2,'0')}-${_selectedDate!.day.toString().padLeft(2,'0')}";

    final docRef =
        FirebaseFirestore.instance.collection('lecturers').doc(lecturerUid);
    final doc = await docRef.get();
    List<dynamic> availability = doc.data()?['availability'] ?? [];

    int index = availability.indexWhere((day) => day['date'] == dateStr);

    List<String> finalTimeslots = [
      ..._existingTimeslots.where((t) => !_removedSelections.contains(t)),
      ..._newSelections
    ];

    if (index >= 0) {
      availability[index]['timeslots'] = finalTimeslots;
    } else {
      availability.add({'date': dateStr, 'timeslots': finalTimeslots});
    }

    await docRef.update({'availability': availability});

    setState(() {
      _existingTimeslots = finalTimeslots;
      _newSelections = [];
      _removedSelections = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Availability updated successfully!")),
    );
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/HomePage'),
        ),
        title: const Text("Update Availability")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _CalendarCard(
              month: _focusedMonth,
              selectedDate: _selectedDate,
              onPrev: _prevMonth,
              onNext: _nextMonth,
              onSelectDate: _loadTimeslotsForDate,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _allTimeslots.map((slot) {
                Color bgColor;
                if (_existingTimeslots.contains(slot) &&
                    !_removedSelections.contains(slot)) {
                  bgColor = Colors.green;
                } else if (_removedSelections.contains(slot)) {
                  bgColor = Colors.red;
                } else if (_newSelections.contains(slot)) {
                  bgColor = const Color.fromARGB(255, 132, 119, 0);
                } else {
                  bgColor = Colors.white;
                }

                return _TimeSlotButton(
                  label: slot,
                  selectedColor: bgColor,
                  onTap: () => _toggleTimeslot(slot),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _confirmChanges,
              child: const Text("Confirm Changes", style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Calendar Widgets ----------------

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
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    return Container(
      padding: const EdgeInsets.all(16),
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
                _monthLabel(month),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left),
                  splashRadius: 18),
              IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                  splashRadius: 18),
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
            spacing: 4,
            runSpacing: 4,
            children: [
              for (int i = 0; i < leadingEmpty; i++) const _DayCell.empty(),

              for (int day = 1; day <= daysInMonth; day++)
                _DayCell(
                  day: day,
                  selected: selectedDate != null &&
                      selectedDate!.year == month.year &&
                      selectedDate!.month == month.month &&
                      selectedDate!.day == day,
                  onTap: DateTime(month.year, month.month, day)
                          .isBefore(DateTime(tomorrow.year, tomorrow.month,
                              tomorrow.day))
                      ? null
                      : () => onSelectDate(
                          DateTime(month.year, month.month, day)),
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
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
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
  const _DayCell({this.day, this.selected = false, this.onTap});
  const _DayCell.empty() : day = null, selected = false, onTap = null;

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
        onTap: disabled ? null : onTap,
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
                          : const Color(0xFF616161)),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Timeslot Widget ----------------

class _TimeSlotButton extends StatelessWidget {
  const _TimeSlotButton({
    required this.label,
    required this.selectedColor,
    this.onTap,
  });

  final String label;
  final Color selectedColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedColor != Colors.white;

    return SizedBox(
      width: 160,
      height: 44,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: isSelected ? selectedColor : const Color(0xFFBDBDBD)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF212121),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
