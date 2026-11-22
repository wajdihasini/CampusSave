import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/role_service.dart';
import '../widgets/state_views.dart';
import 'admin/admin_home_screen.dart';
import 'merchant/merchant_home_screen.dart';
import 'student/student_home_screen.dart';
import 'profile_screen.dart';

class RoleHomeScreen extends StatefulWidget {
  final User user;
  const RoleHomeScreen({super.key, required this.user});
  @override State<RoleHomeScreen> createState() => _RoleHomeScreenState();
}
class _RoleHomeScreenState extends State<RoleHomeScreen> {
  late Future<UserRole> _fut;
  @override void initState() { super.initState(); _fut = RoleService().fetchRole(widget.user); }
  void _reload() {
    _fut = RoleService().fetchRole(widget.user);
    setState(() {});
  }
  @override Widget build(BuildContext context) => FutureBuilder<UserRole>(future: _fut,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done)
        return Scaffold(appBar: AppBar(title: const Text('CampusSave')), body: const LoadingView());
      if (snap.hasError)
        return Scaffold(appBar: AppBar(title: const Text('CampusSave')),
          body: ErrorView(message: 'Could not load your profile.', onRetry: _reload));
      final role = snap.data!;
      if (role == UserRole.student) return StudentHomeScreen(user: widget.user, role: role);
      if (role == UserRole.merchant) return MerchantHomeScreen(user: widget.user, role: role);
      if (role == UserRole.admin) return AdminHomeScreen(user: widget.user);
      return _PendingScreen(user: widget.user, role: role);
    });
}

class _PendingScreen extends StatelessWidget {
  final User user; final UserRole role;
  const _PendingScreen({required this.user, required this.role});
  @override Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('CampusSave'), actions: [
        IconButton(icon: const Icon(Icons.account_circle_outlined), tooltip: 'Profile',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfileScreen(user: user, role: role)))),
      ]),
      body: Center(child: Padding(padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: s.secondaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.hourglass_top, size: 56, color: s.secondary)),
          const SizedBox(height: 20),
          Text('Pending Approval', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('Your merchant account is waiting for admin validation.\n'
            'You will be notified once approved.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton.icon(icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
            onPressed: () => AuthService().signOut()),
        ]))));
  }
}
