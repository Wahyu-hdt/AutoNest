import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/faq_page.dart';
import '../pages/bengkel_page.dart';
import '../pages/profile_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(key: ValueKey('HomePage')),
    const FaqPage(key: ValueKey('FaqPage')),
    const BengkelPage(key: ValueKey('BengkelPage')),
    const ProfilePage(key: ValueKey('ProfilePage')),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.question_answer, 'label': 'FAQ'},
    {'icon': Icons.build_outlined, 'label': 'Workshop'},
    {'icon': Icons.person_outline, 'label': 'Profile'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Efek Slide:  dari kanan ke kiri
          const begin = Offset(1.0, 0.0); // 1.0 berarti di luar layar ke kanan
          const end = Offset.zero; // 0.0 berarti posisi asli (tengah)
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },

        child: _pages[_selectedIndex],
      ),

      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF252525),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: _buildNavItem(
                icon: _navItems[index]['icon'],
                label: _navItems[index]['label'],
                isSelected: _selectedIndex == index,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    // Animasi
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
          isSelected
              ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF191919), Color(0xFF3A3A3A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
              )
              : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 28),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
