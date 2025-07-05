import 'package:autonest/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:autonest/snackbar/main_wrapper.dart';
import 'package:autonest/pages/add_car_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotPasswordEmailController =
      TextEditingController();

  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordEmailController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (!email.contains('@') || !email.contains('.')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
      return;
    }

    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your password.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String? errorMessage = await _authService.login(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );

      final String? userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        try {
          final List<Map<String, dynamic>> cars = await _supabase
              .from('Mobil')
              .select('id')
              .eq('user_profil_id', userId)
              .limit(1);

          if (mounted) {
            if (cars.isEmpty) {
              // Jika tidak ada data mobil, arahkan ke AddCarPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddCarPage()),
              );
            } else {
              // Jika ada data mobil, arahkan ke MainWrapper
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const MainWrapper(), // Langsung ke MainWrapper
                ),
              );
            }
          }
        } on PostgrestException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error checking car data: ${e.message}')),
            );
            // Fallback: Arahkan ke MainWrapper jika ada error saat cek mobil
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => const MainWrapper(), // Fallback ke MainWrapper
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An unexpected error occurred: $e')),
            );
            // Fallback: Arahkan ke MainWrapper jika ada error tak terduga
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => const MainWrapper(), // Fallback ke MainWrapper
              ),
            );
          }
        }
      } else {
        // Jika userId null (seharusnya tidak terjadi setelah login berhasil),
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const MainWrapper(), // Fallback ke MainWrapper
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    }
  }

  // Overlay forgot password
  Future<void> _showForgotPasswordDialog() async {
    _forgotPasswordEmailController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232323),
          title: const Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  'Enter your email to receive a password reset link.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _forgotPasswordEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF191919),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Send Reset Link',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () async {
                final String email = _forgotPasswordEmailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter your email.')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();

                setState(() {
                  _isLoading = true;
                });
                final String? errorMessage = await _authService
                    .sendPasswordResetEmail(email);
                setState(() {
                  _isLoading = false;
                });
                // message snackbar
                if (mounted) {
                  if (errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset link sent! Check your email.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to send reset link: $errorMessage',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // konten utama
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 24),
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
                            _buildTextField(
                              icon: Icons.email,
                              hint: 'Email',
                              controller: _emailController,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              icon: Icons.lock,
                              hint: 'Password',
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              suffixIcon:
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                              onSuffixIconTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
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
                                onPressed: _isLoading ? null : _signIn,
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
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          'Login',
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
    TextEditingController? controller,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon:
            suffixIcon != null
                ? IconButton(
                  icon: Icon(suffixIcon, color: Colors.white),
                  onPressed: onSuffixIconTap,
                )
                : null,
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
