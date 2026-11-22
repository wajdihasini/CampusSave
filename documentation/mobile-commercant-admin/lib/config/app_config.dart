import 'package:firebase_core/firebase_core.dart';

class AppConfig {
  // Sur émulateur Android Studio, 10.0.2.2 pointe vers localhost (port 5000 du backend Express)
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api';

  // Remplace ces valeurs par celles du projet Firebase "campussave" de ton collègue
  // (Console Firebase -> Paramètres du projet -> Application Android, ou génère firebase_options.dart avec FlutterFire CLI)
  static const FirebaseOptions androidFirebaseOptions = FirebaseOptions(
    apiKey: 'REMPLACER_PAR_API_KEY_FIREBASE',
    appId: 'REMPLACER_PAR_APP_ID_ANDROID',
    messagingSenderId: 'REMPLACER_PAR_SENDER_ID',
    projectId: 'campussave',
    storageBucket: 'campussave.appspot.com',
  );
}
