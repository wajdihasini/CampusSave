import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/app_provider.dart';
import 'screens/admin_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/merchant_home_screen.dart';
import 'screens/student_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Utilise google-services.json automatiquement sur Android si présent, sinon AppConfig.androidFirebaseOptions
    await Firebase.initializeApp();
  } catch (_) {
    await Firebase.initializeApp(options: AppConfig.androidFirebaseOptions);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..restoreSession(),
      child: const CampusSaveApp(),
    ),
  );
}

class CampusSaveApp extends StatelessWidget {
  const CampusSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    Widget homeScreen;
    if (user == null) {
      homeScreen = const LoginScreen();
    } else if (user.role == 'merchant') {
      homeScreen = const MerchantHomeScreen();
    } else if (user.role == 'admin') {
      homeScreen = const AdminHomeScreen();
    } else {
      homeScreen = const StudentHomeScreen();
    }

    return MaterialApp(
      title: 'CampusSave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0F766E),
        useMaterial3: true,
      ),
      home: homeScreen,
    );
  }
}
