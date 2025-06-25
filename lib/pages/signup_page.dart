import 'package:autonest/service/auth.dart'; // Pastikan path ini benar
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // TextEditingController untuk setiap input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Memanggil fungsi auth supabase
  final AuthService _authService = AuthService();

  // State untuk visibility password
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // State untuk indikator loading saat proses Signup
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi tambahan jika diperlukan
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget dihapus untuk mencegah memory leak
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani proses Signup
  Future<void> _signUp() async {
    // Validasi password: Pastikan password cocok
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match!'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              top: 60.0,
              left: 20.0,
              right: 20.0,
            ), // Menambahkan margin
            duration: Duration(seconds: 4), // Durasi tampil
            backgroundColor: Colors.red, // Warna untuk error
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ), // Bentuk membulat
          ),
        );
      }
      return;
    }

    // Ambil nilai input setelah trim
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String name = _nameController.text.trim();

    // Validasi Email
    if (!email.contains('@') || !email.contains('.')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              top: 60.0,
              left: 20.0,
              right: 20.0,
            ), // Menambahkan margin
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

    // Validasi Nama
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your name.'),
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

    // Panggil fungsi signup dari AuthService
    final String? errorMessage = await _authService.signup(
      email,
      password,
      name: name, // Pastikan 'name' diteruskan ke AuthService
    );

    // Periksa apakah widget masih mounted setelah operasi asinkron selesai
    if (!mounted) return;

    setState(() {
      _isLoading = false; // Sembunyikan indikator loading
    });

    if (errorMessage == null) {
      // Signup berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign Up Successful! Please login.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green, // Warna untuk sukses
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
      Navigator.pushReplacementNamed(context, '/login'); // Routing ke login
    } else {
      // Signup gagal, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0), //
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red, // Warna untuk error
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    }
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
              // Bagian atas
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
                    const SizedBox(height: 24),
                    Center(
                      child: Image.asset(
                        'assets/images/LogoAutoNest.png', // Pastikan path gambar ini benar
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      'Let’s Start Our\nJourney.',
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

              // Kontainer bawah lengkung
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
                            //Kolom Nama Akun
                            _buildTextField(
                              icon: Icons.person,
                              hint: 'Name',
                              controller: _nameController,
                            ),
                            //Kolom Email
                            const SizedBox(height: 20),
                            _buildTextField(
                              icon: Icons.email,
                              hint: 'Email',
                              controller: _emailController,
                            ),
                            // Kolom Password
                            const SizedBox(height: 20),
                            _buildTextField(
                              icon: Icons.lock,
                              hint: 'Password',
                              controller: _passwordController,
                              obscureText:
                                  !_isPasswordVisible, // Kontrol Password terlihat atau tidak
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
                            // Kolom Konfirmasi Password
                            const SizedBox(height: 20),
                            _buildTextField(
                              icon: Icons.lock,
                              hint: 'Confirm Password',
                              controller: _confirmPasswordController,
                              obscureText:
                                  !_isConfirmPasswordVisible, // Kontrol Password terlihat atau tidak
                              suffixIcon:
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                              onSuffixIconTap: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                // Panggil fungsi Signup saat tombol ditekan
                                onPressed:
                                    _isLoading
                                        ? null
                                        : _signUp, // Nonaktifkan tombol saat loading
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
                                          'Sign Up',
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
                                    "Already have an account? ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap:
                                        () => Navigator.pushNamed(
                                          context,
                                          '/login',
                                        ),
                                    child: const Text(
                                      'Login',
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
