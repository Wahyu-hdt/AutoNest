import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_signup.dart';
import 'pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://kxyjtmczfbwekfoyegob.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4eWp0bWN6ZmJ3ZWtmb3llZ29iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4Njk4NDAsImV4cCI6MjA2NjQ0NTg0MH0.B6SFaK5spPo7KuW3lTV-njfCMwwqFIq0xYwhxWiS_CM",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Lato'),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/loginsignup': (context) => LoginSignup(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
