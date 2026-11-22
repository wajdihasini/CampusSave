import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_role.dart';

class RoleService {
  static const _adminEmail = 'admin@campussave.tn';

  /// Fetches role from GET /api/me (source of truth).
  /// Falls back to SharedPreferences cache if network is unavailable.
  Future<UserRole> fetchRole(User user) async {
    if (user.email?.toLowerCase() == _adminEmail) return UserRole.admin;
    try {
      final token = await user.getIdToken();
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/me'),
               headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        if ((j['blocked'] as bool?) == true) {
          await FirebaseAuth.instance.signOut();
          return UserRole.student; // login screen will show
        }
        final roleStr = j['role'] as String? ?? 'student';
        final shop    = j['shop'] as Map<String, dynamic>?;
        UserRole role;
        if      (roleStr == 'admin')    role = UserRole.admin;
        else if (roleStr == 'merchant') {
          role = (shop?['approved'] == true) ? UserRole.merchant : UserRole.merchantPending;
        } else { role = UserRole.student; }

        // Cache locally for offline start.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role_${user.uid}', role.name);
        return role;
      }
      // Non-200 → fall through to cache.
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    return UserRole.fromString(prefs.getString('role_${user.uid}')) ?? UserRole.student;
  }
}
