import 'package:flutter/material.dart';

class ConsultationNotesPage extends StatefulWidget {
  const ConsultationNotesPage({super.key});

  @override
  State<ConsultationNotesPage> createState() => _ConsultationNotesPageState();
}

class _ConsultationNotesPageState extends State<ConsultationNotesPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_NotesData> _notes = const [
    _NotesData(
      roleLabel: 'Lecturers Notes',
      name: 'Wang Wei',
      initials: 'LW',
      avatarColor: Color(0xFFF05B6C),
      note:
          'Lecturers notes bla bla bla',
    ),
    _NotesData(
      roleLabel: 'Students Notes',
      name: 'Chew Kai Mark',
      initials: 'SK',
      avatarColor: Color(0xFFD2B3E5),
      note:
          'Students notes bla bla bla',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _notes.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = _currentIndex > 0;
    final canGoForward = _currentIndex < _notes.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
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
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final data = _notes[index];
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                      child: _NotesCard(data: data),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ArrowButton(
                    icon: Icons.chevron_left,
                    enabled: canGoBack,
                    onTap: () => _goToPage(_currentIndex - 1),
                  ),
                  const SizedBox(width: 20),
                  _ArrowButton(
                    icon: Icons.chevron_right,
                    enabled: canGoForward,
                    onTap: () => _goToPage(_currentIndex + 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NotesData {
  final String roleLabel;
  final String name;
  final String initials;
  final Color avatarColor;
  final String note;

  const _NotesData({
    required this.roleLabel,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.note,
  });
}

class _NotesCard extends StatelessWidget {
  final _NotesData data;

  const _NotesCard({required this.data});

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(color: const Color(0xFF2A1F18), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: data.avatarColor,
                  child: Text(
                    data.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.roleLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.name,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2A1F18),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 26,
                  color: Color(0xFF1D2130),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data.note,
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

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF111111) : const Color(0xFFBDBDBD);
    return InkResponse(
      onTap: enabled ? onTap : null,
      radius: 28,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
