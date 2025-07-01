import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: const Color(0xFF232323),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      body: const Center(
        child: Text(
          'This is the FAQ Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
