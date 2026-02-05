// for scheduleLecture.dart

import 'package:flutter/material.dart';

class Reload extends StatefulWidget {
  const Reload({super.key});

  @override
  State<Reload> createState() => _ReloadState();
}

class _ReloadState extends State<Reload> {
  
  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/scheduleLecture');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
  }
}