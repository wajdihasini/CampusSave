import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../profile_screen.dart';
import '../../models/user_role.dart';
import 'admin_dashboard_tab.dart';
import 'merchants_tab.dart';
import 'users_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  final User user;
  const AdminHomeScreen({super.key, required this.user});
  @override State<AdminHomeScreen> createState() => _State();
}
class _State extends State<AdminHomeScreen> {
  int _idx = 0;
  static const _titles = ['Dashboard', 'Users', 'Merchants'];
  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: Text('Admin – ${_titles[_idx]}'),
      backgroundColor: const Color(0xFF1A237E),
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => Navigator.of(c).push(MaterialPageRoute(
            builder: (_) => ProfileScreen(user: widget.user, role: UserRole.admin)))),
      ]),
    body: IndexedStack(index: _idx, children: [
      const AdminDashboardTab(),
      const UsersTab(),
      const MerchantsTab(),
    ]),
    bottomNavigationBar: NavigationBar(selectedIndex: _idx,
      onDestinationSelected: (i) => setState(() => _idx = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people), label: 'Users'),
        NavigationDestination(icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront), label: 'Merchants'),
      ]));
}
