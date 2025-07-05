import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_signup.dart';
import 'pages/home_page.dart';
import 'snackbar/main_wrapper.dart';
import 'pages/faq_page.dart';
import 'pages/bengkel_page.dart';
import 'pages/profile_page.dart';
import 'pages/add_car_page.dart';

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
        '/addcar': (context) => const AddCarPage(),
      },
    );
  }
}
