import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_role.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override String toString() => message;
}

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) { throw AuthException(_msg(e.code)); }
  }

  /// Creates Firebase user, then POSTs to /api/users to create the Firestore profile.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String businessName = '',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await cred.user?.updateDisplayName(name.trim());

      final token = await cred.user!.getIdToken();
      final body  = <String, dynamic>{
        'name': name.trim(),
        'role': role == UserRole.merchant ? 'merchant' : 'student',
        if (role == UserRole.merchant && businessName.trim().isNotEmpty)
          'shopName': businessName.trim(),
      };

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(ApiConfig.timeout);

      // 409 = profile already exists (acceptable); anything else is an error.
      if (res.statusCode != 201 && res.statusCode != 409) {
        await _auth.signOut();
        final err = _safeDecode(res.body)?['error'] ?? 'Backend error (${res.statusCode})';
        throw AuthException('Profile not created: $err');
      }
    } on FirebaseAuthException catch (e) { throw AuthException(_msg(e.code)); }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return;
      throw AuthException(_msg(e.code));
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name.trim());
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) { throw AuthException(_msg(e.code)); }
  }

  Future<void> signOut() => _auth.signOut();

  Future<String?> getIdToken({bool forceRefresh = false}) async =>
      await _auth.currentUser?.getIdToken(forceRefresh);

  Map<String, dynamic>? _safeDecode(String body) {
    try { return jsonDecode(body) as Map<String, dynamic>; } catch (_) { return null; }
  }

  String _msg(String code) {
    switch (code) {
      case 'invalid-email':          return 'Invalid email address.';
      case 'user-disabled':          return 'Account disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':     return 'Incorrect email or password.';
      case 'email-already-in-use':   return 'An account already exists for this email.';
      case 'weak-password':          return 'Password is too weak (min. 6 chars).';
      case 'network-request-failed': return 'Network error. Check your connection.';
      case 'too-many-requests':      return 'Too many attempts. Try again later.';
      default:                       return 'Authentication error ($code).';
    }
  }
}
