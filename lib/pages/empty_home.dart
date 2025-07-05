import 'package:flutter/material.dart';
import 'package:autonest/pages/add_car_page.dart';
import 'package:autonest/snackbar/main_wrapper.dart';

class EmptyHomePage extends StatelessWidget {
  const EmptyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color from the image
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Car icon with cross
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/emptyicon.png',
                  width: 100,
                  height: 100,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 48),

            const Text(
              'Your Garage is Empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Description text
            const Text(
              'Add your vehicle to monitor its status, schedule maintenance, and control features — all from your phone.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCarPage()),
                );

                if (result == true) {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainWrapper(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add Vehicle',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
