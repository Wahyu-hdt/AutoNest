import 'package:flutter/material.dart';

class StatusDetailPage extends StatelessWidget {
  const StatusDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        title: const Text(
          'Status Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Halaman Detail Status Mobil',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
