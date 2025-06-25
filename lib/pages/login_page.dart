import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color topColor = Color(0xFF232323);
    const Color containerColor = Color(0xFF0F0F0F);

    return Scaffold(
      backgroundColor: topColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Bagian Atas: Logo dan Welcome
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamed(context, "/loginsignup");
                      },
                    ),
                    Center(
                      child: Image.asset(
                        'assets/images/LogoAutoNest.png',
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      'Welcome Back.',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bagian bawah
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: const BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white12,
                        blurRadius: 16,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(icon: Icons.email, hint: 'Email'),
                            const SizedBox(height: 20),
                            _buildTextField(
                              icon: Icons.lock,
                              hint: 'Password',
                              suffixIcon: Icons.visibility_off,
                              obscureText: true,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: const BorderSide(color: Colors.white),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap:
                                        () => Navigator.pushNamed(
                                          context,
                                          '/signup',
                                        ),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    bool obscureText = false,
    IconData? suffixIcon,
  }) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon:
            suffixIcon != null ? Icon(suffixIcon, color: Colors.white) : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
