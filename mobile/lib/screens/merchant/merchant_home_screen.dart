import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../profile_screen.dart';
import 'merchant_dashboard_tab.dart';
import 'merchant_orders_tab.dart';
import 'my_offers_tab.dart';

class MerchantHomeScreen extends StatefulWidget {
  final User user; final UserRole role;
  const MerchantHomeScreen({super.key, required this.user, required this.role});
  @override State<MerchantHomeScreen> createState() => _State();
}
class _State extends State<MerchantHomeScreen> {
  int _idx = 0;
  static const _titles = ['My Offers', 'Incoming Orders', 'Dashboard'];
  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text(_titles[_idx]), actions: [
      IconButton(icon: const Icon(Icons.account_circle_outlined), tooltip: 'Profile',
        onPressed: () => Navigator.of(c).push(MaterialPageRoute(
          builder: (_) => ProfileScreen(user: widget.user, role: widget.role)))),
    ]),
    body: IndexedStack(index: _idx, children: [
      MyOffersTab(merchantId: widget.user.uid),
      MerchantOrdersTab(merchantId: widget.user.uid),
      MerchantDashboardTab(merchantId: widget.user.uid),
    ]),
    bottomNavigationBar: NavigationBar(selectedIndex: _idx,
      onDestinationSelected: (i) => setState(() => _idx = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.local_offer_outlined),
          selectedIcon: Icon(Icons.local_offer), label: 'Offers'),
        NavigationDestination(icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart), label: 'Dashboard'),
      ]));
}
