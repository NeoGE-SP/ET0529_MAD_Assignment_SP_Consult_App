import 'package:flutter/material.dart';

class Newconsult2 extends StatefulWidget {
  const Newconsult2({super.key});

  @override
  State<Newconsult2> createState() => _Newconsult2State();
}

class _Newconsult2State extends State<Newconsult2> {
  DateTime _focusedMonth = DateTime(2026, 01);
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pushNamed(context, '/newConsult1'),),
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
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Consultation',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _CalendarCard(
                month: _focusedMonth,
                selectedDate: _selectedDate,
                onPrev: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    );
                  });
                },
                onNext: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    );
                  });
                },
                onSelectDate: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _TimeSlotButton(
                    label: '08:00 - 09:00',
                    selected: _selectedTime == '08:00 - 09:00',
                    onTap: () {
                      setState(() {
                        _selectedTime = '08:00 - 09:00';
                      });
                    },
                  ),
                  _TimeSlotButton(
                    label: '13:00 - 14:00',
                    selected: _selectedTime == '13:00 - 14:00',
                    onTap: () {
                      setState(() {
                        _selectedTime = '13:00 - 14:00';
                      });
                    },
                  ),
                  _TimeSlotButton(
                    label: '14:00 - 15:00',
                    selected: _selectedTime == '14:00 - 15:00',
                    onTap: () {
                      setState(() {
                        _selectedTime = '14:00 - 15:00';
                      });
                    },
                  ),
                  const _TimeSlotButton(
                    label: '15:00 - 16:00',
                    selected: false,
                    disabled: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 240,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0443E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Schedule Consultation',
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
              for (int i = 0; i < leadingEmpty; i++)
                const _DayCell.empty(),
              for (int day = 1; day <= daysInMonth; day++)
                _DayCell(
                  day: day,
                  selected: _isSameDay(
                    selectedDate,
                    DateTime(month.year, month.month, day),
                  ),
                  onTap: () =>
                      onSelectDate(DateTime(month.year, month.month, day)),
                ),
              for (int i = 0; i < trailingEmpty; i++)
                const _DayCell.empty(),
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
    if (day == null) {
      return const SizedBox(width: 44, height: 36);
    }

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
              color: selected ? const Color(0xFFE0443E) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF616161),
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
