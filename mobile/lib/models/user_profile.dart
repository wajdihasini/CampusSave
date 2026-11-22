import 'user_role.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final bool blocked;
  final int ecoPoints;
  final Map<String, dynamic>? shop;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.blocked = false,
    this.ecoPoints = 0,
    this.shop,
  });

  bool get shopApproved => shop?['approved'] == true;

  factory UserProfile.fromJson(Map<String, dynamic> j, String uid) {
    final roleStr = j['role'] as String? ?? 'student';
    final shop = j['shop'] as Map<String, dynamic>?;
    UserRole role;
    if (roleStr == 'admin') {
      role = UserRole.admin;
    } else if (roleStr == 'merchant') {
      role = (shop?['approved'] == true)
          ? UserRole.merchant
          : UserRole.merchantPending;
    } else {
      role = UserRole.student;
    }
    return UserProfile(
      uid: uid,
      name: (j['name'] as String?) ?? '',
      email: (j['email'] as String?) ?? '',
      phone: (j['phone'] as String?) ?? '',
      role: role,
      blocked: (j['blocked'] as bool?) ?? false,
      ecoPoints: (j['ecoPoints'] as int?) ?? 0,
      shop: shop,
    );
  }
}
