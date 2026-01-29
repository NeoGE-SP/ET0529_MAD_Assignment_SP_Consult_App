import 'package:flutter/material.dart';

class Newconsult1 extends StatefulWidget {
  const Newconsult1({super.key});

  @override
  State<Newconsult1> createState() => _Newconsult1State();
}

class _Newconsult1State extends State<Newconsult1> {
  String? _selectedModule;
  String? _selectedMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/img/sp_logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFBDBDBD)),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, size: 28),
                  splashRadius: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'New Consultation',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              const Text(
                'Module Name / Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _OptionCard(
                    label: 'ET0529/MAD',
                    tint: Color(0xFFF3E9F5),
                    icon: Icons.phone_android,
                    selected: _selectedModule == 'ET0529/MAD',
                    onTap: () {
                      setState(() {
                        _selectedModule = 'ET0529/MAD';
                      });
                    },
                  ),
                  _OptionCard(
                    label: 'ET1010/MAPP',
                    tint: Color(0xFFE6F0FA),
                    icon: Icons.memory,
                    selected: _selectedModule == 'ET1010/MAPP',
                    onTap: () {
                      setState(() {
                        _selectedModule = 'ET1010/MAPP';
                      });
                    },
                  ),
                  _OptionCard(
                    label: 'ET0744/FSD',
                    tint: Color(0xFFF2F2F2),
                    icon: Icons.desktop_windows,
                    selected: _selectedModule == 'ET0744/FSD',
                    onTap: () {
                      setState(() {
                        _selectedModule = 'ET0744/FSD';
                      });
                    },
                  ),
                  _OptionCard(
                    label: 'ET0602/AM2',
                    tint: Color(0xFFF6ECE4),
                    icon: Icons.functions,
                    selected: _selectedModule == 'ET0602/AM2',
                    onTap: () {
                      setState(() {
                        _selectedModule = 'ET0602/AM2';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Lecturer Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Select lecturer',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'lect1', child: Text('Mr Lee')),
                  DropdownMenuItem(value: 'lect2', child: Text('Mr Lim')),
                  DropdownMenuItem(value: 'lect3', child: Text('Ms Tan')),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 24),
              const Text(
                'Preferred Mode of Consultation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OptionCard(
                      label: 'Physical',
                      tint: Color(0xFFE9F3F6),
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
                  SizedBox(width: 16),
                  Expanded(
                    child: _OptionCard(
                      label: 'Online',
                      tint: Color(0xFFF7E7DC),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0443E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Proceed',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white  ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
        width: 150,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          boxShadow: [
            if (selected)
              const BoxShadow(
                color: Color(0x26E0443E),
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            else
              const BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
          ],
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
