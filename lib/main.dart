import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_user.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ResponsiApp());
}

class ResponsiApp extends StatefulWidget {
  const ResponsiApp({super.key});

  @override
  State<ResponsiApp> createState() => _ResponsiAppState();
}

class _ResponsiAppState extends State<ResponsiApp> {
  Future<AppUser?> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final name = prefs.getString('name');
    final email = prefs.getString('email');

    if (token != null && name != null && email != null) {
      return AppUser(id: 0, name: name, email: email, token: token);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsi 2 Mobile Paket 1 (H1D023010)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
        ),
      ),
      home: FutureBuilder<AppUser?>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoginPage();
          }
          final user = snapshot.data;
          if (user == null || user.token.isEmpty) {
            return const LoginPage();
          }
          return HomePage(user: user);
        },
      ),
    );
  }
}
