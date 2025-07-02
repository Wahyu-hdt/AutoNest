import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_signup.dart';
import 'pages/home_page.dart';
import 'snackbar/main_wrapper.dart';
import 'pages/faq_page.dart';
import 'pages/bengkel_page.dart';
import 'pages/profile_page.dart';
import 'pages/resetpassword_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env/.env");
  print("SUPABASE_URL loaded: ${dotenv.env['SUPABASE_URL']}");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    debugPrint('MyApp initState: Inisialisasi deep links...');
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    debugPrint('Inisialisasi AppLinks...');

    _handleInitialLink();

    _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('Menerima tautan aplikasi dari stream: $uri');
        _handleIncomingLink(uri);
      },
      onError: (err) {
        debugPrint('Error stream tautan aplikasi: $err');
      },
    );
  }

  void _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        debugPrint('Tautan aplikasi awal terdeteksi: $uri');
        // Tunggu sampai widget tree siap
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('Menangani tautan awal setelah callback post frame: $uri');
          _handleIncomingLink(uri);
        });
      } else {
        debugPrint('Tidak ada tautan aplikasi awal yang ditemukan.');
      }
    } catch (e) {
      debugPrint('Gagal mendapatkan tautan awal: $e');
    }
  }

  void _handleIncomingLink(Uri uri) {
    debugPrint('--- Memulai pemrosesan tautan masuk ---');
    debugPrint('URI Tautan Lengkap: ${uri.toString()}');
    debugPrint('Path: ${uri.path}');
    debugPrint('Parameter Kueri: ${uri.queryParameters}');
    debugPrint('Skema: ${uri.scheme}');
    debugPrint('Host: ${uri.host}');

    //  callback otentikasi Supabase
    if (uri.path == '/auth/callback') {
      debugPrint(
        'Tautan dikenali sebagai /auth/callback. Memanggil _handleAuthCallback.',
      );
      _handleAuthCallback(uri);
    } else {
      debugPrint(
        'Jalur tautan tidak tertangani: ${uri.path}. Mengarahkan ke login/signup default.',
      );
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/loginsignup',
        (route) => false,
      );
    }
    debugPrint('--- Selesai memproses tautan masuk ---');
  }

  void _handleAuthCallback(Uri uri) async {
    final type = uri.queryParameters['type'];
    final accessToken = uri.queryParameters['access_token'];

    debugPrint('Di dalam _handleAuthCallback:');
    debugPrint('Parameter tipe callback otentikasi: $type');
    debugPrint('AccessToken callback otentikasi ada: ${accessToken != null}');
    debugPrint(
      'AccessToken callback otentikasi (10 karakter pertama): ${accessToken?.substring(0, 10)}...',
    ); // Masking token demi keamanan

    try {
      // --- Tangani Pemulihan Kata Sandi ---
      if (type == 'recovery' && accessToken != null) {
        debugPrint(
          'Callback otentikasi: Terdeteksi tipe "recovery" dengan accessToken.',
        );
        final response = await Supabase.instance.client.auth.setSession(
          accessToken,
        );

        if (response.session != null) {
          // Sesi pemulihan berhasil dibuat (token valid)
          debugPrint(
            'Callback otentikasi: Sesi pemulihan berhasil dibuat. Mengarahkan ke halaman reset password.',
          );
          _navigateToResetPassword();
        } else {
          debugPrint(
            'Callback otentikasi: Gagal membuat sesi pemulihan. Sesi Respons adalah null.',
          );
          _showMessage(
            'Gagal memproses tautan reset password. Silakan coba lagi.',
            isError: true,
          );
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/loginsignup',
            (route) => false,
          );
        }
      }
      // Tangani Konfirmasi Email
      else if (type == 'signup') {
        debugPrint('Callback otentikasi: Terdeteksi tipe "signup".');
        _showMessage(
          'Email dikonfirmasi! Anda sekarang dapat masuk.',
          isError: false,
        );
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/loginsignup',
          (route) => false,
        );
      }
      // Tangani Callback Otentikasi Lainnya
      else if (accessToken != null) {
        debugPrint(
          'Callback otentikasi: Cabang default (accessToken ada, tetapi bukan recovery/signup). Mencoba mengatur sesi dan mengarahkan ke beranda.',
        );
        await Supabase.instance.client.auth.setSession(accessToken);
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home', // Mengarahkan ke beranda jika pengguna berhasil masuk via magic link
          (route) => false,
        );
      }
      // --- Fallback untuk Tipe Tidak Dikenal atau Access Token Hilang ---
      else {
        debugPrint(
          'Callback otentikasi: Tidak ada access token atau tipe tidak dikenal. Mengarahkan ke login/signup.',
        );
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/loginsignup',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error callback otentikasi tertangkap di try-catch: $e');
      _showMessage(
        'Gagal memproses tautan otentikasi: ${e.toString()}',
        isError: true,
      );
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/loginsignup', // Selalu mengarahkan ke login jika terjadi error yang tidak tertangani
        (route) => false,
      );
    }
  }

  void _navigateToResetPassword() {
    debugPrint('Mengarahkan ke rute /resetpassword.');
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/resetpassword',
      (route) => false,
    );
  }

  void _showMessage(String message, {required bool isError}) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      debugPrint('Menampilkan Snackbar: $message (Error: $isError)');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
    } else {
      debugPrint(
        'Tidak dapat menampilkan Snackbar: Konteks adalah null. Pesan: $message',
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoNest',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: ThemeData(fontFamily: 'Lato'),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/loginsignup': (context) => const LoginSignup(),
        '/home': (context) => const HomePage(),
        '/mainwrapper': (context) => const MainWrapper(),
        '/faq': (context) => const FaqPage(),
        '/bengkel': (context) => const BengkelPage(),
        '/profile': (context) => const ProfilePage(),
        '/resetpassword': (context) => const ResetPasswordPage(),
      },
    );
  }
}
