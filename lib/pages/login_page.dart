import 'package:autonest/service/auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // TextEditingController untuk setiap input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controller untuk Forgot Password
  final TextEditingController _forgotPasswordEmailController =
      TextEditingController();

  // Memanggil fungsi auth supabase
  final AuthService _authService = AuthService();

  // State untuk mengelola visibilitas password
  bool _isPasswordVisible = false;

  // State untuk indikator loading saat proses Login
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordEmailController.dispose();
    super.dispose();
  }

  // Fungsi untuk Login
  Future<void> _signIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Validasi Email
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

    // Validasi Password
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
      _isLoading = true; // Tampilkan indikator loading
    });

    // Panggil fungsi Login dari AuthService
    final String? errorMessage = await _authService.login(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false; // Sembunyikan indikator loading
    });

    if (errorMessage == null) {
      // Login berhasil
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
      Navigator.pushReplacementNamed(
        context,
        '/mainwrapper',
      ); // Routing ke halaman utama
    } else {
      // Login gagal, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
          ), // Pesan error dari AuthService (Invalid email or password, dll.)
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red, // Warna untuk error
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    }
  }

  // Fungsi  Forgot Password
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
                  // Tampilkan snackbar di dalam dialog jika email kosong
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter your email.')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();

                setState(() {
                  _isLoading = true;
                }); // Tampilkan loading di halaman utama
                final String? errorMessage = await _authService
                    .sendPasswordResetEmail(email);
                setState(() {
                  _isLoading = false;
                }); // Sembunyikan loading

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
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
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
                            //Kolom email
                            _buildTextField(
                              icon: Icons.email,
                              hint: 'Email',
                              controller:
                                  _emailController, // Hubungkan controller
                            ),
                            const SizedBox(height: 20),

                            //Kolom password
                            _buildTextField(
                              icon: Icons.lock,
                              hint: 'Password',
                              controller:
                                  _passwordController, // Hubungkan controller
                              obscureText:
                                  !_isPasswordVisible, // Gunakan state password
                              suffixIcon:
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                              onSuffixIconTap: () {
                                setState(() {
                                  _isPasswordVisible =
                                      !_isPasswordVisible; // Ubah state password
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                    _showForgotPasswordDialog, // Panggil dialog
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
                                // Panggil fungsi Login saat tombol ditekan
                                onPressed:
                                    _isLoading
                                        ? null
                                        : _signIn, // Nonaktifkan tombol saat loading
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
                                        ) // Tampilkan loading
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
