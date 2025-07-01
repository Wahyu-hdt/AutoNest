import 'package:flutter/material.dart';

class BengkelPage extends StatelessWidget {
  const BengkelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bengkel'),
        backgroundColor: const Color(0xFF232323),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      body: const Center(
        child: Text(
          'This is the Bengkel Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
