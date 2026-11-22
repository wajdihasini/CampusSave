import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }

  Future<AppUser> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    final profile = await fetchUserProfile(uid);

    if (profile.blocked) {
      await _auth.signOut();
      throw Exception('Ce compte a été bloqué par un administrateur.');
    }

    await _saveFcmToken(uid);
    return profile;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role, // 'student' ou 'merchant'
  }) async {
    final safeRole = role == 'merchant' ? 'merchant' : 'student';
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    final now = DateTime.now().millisecondsSinceEpoch;

    final userData = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'role': safeRole,
      'blocked': false,
      'createdAt': now,
    };

    await _firestore.collection('users').doc(uid).set(userData);
    await _saveFcmToken(uid);

    return AppUser.fromMap(uid, userData);
  }

  Future<AppUser> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Profil utilisateur introuvable dans Firestore (users/$uid).');
    }
    return AppUser.fromMap(uid, doc.data()!);
  }

  Future<void> _saveFcmToken(String uid) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(uid).update({'fcmToken': token});
      }
    } catch (_) {
      // Ignorer si les services Google Play ne sont pas configurés sur l'appareil
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
