import 'package:flutter/material.dart';
import 'package:autonest/service/auth.dart'; // Pastikan path ini benar

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService(); // Inisialisasi AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: const Color(0xFF232323), // Warna AppBar yang serasi
        foregroundColor: Colors.white, // Warna teks AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Panggil fungsi logout dari AuthService
              await _authService.logout(context);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: const Color(
        0xFF0F0F0F,
      ), // Warna latar belakang yang serasi
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              SizedBox(height: 20),
              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'You have successfully logged in.',
                style: TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
