import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../splash_screen.dart';
import '../role_home_screen.dart';
import 'login_screen.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override Widget build(BuildContext c) => StreamBuilder<User?>(
    stream: AuthService().userChanges,
    builder: (c, snap) {
      if (snap.connectionState == ConnectionState.waiting)
        return const SplashScreen();
      final user = snap.data;
      if (user == null) return const LoginScreen();
      return RoleHomeScreen(key: ValueKey(user.uid), user: user);
    });
}
