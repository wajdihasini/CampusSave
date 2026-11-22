import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      appBar: AppBar(
        title: const Text('Administration', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(onPressed: provider.loadAdminData, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: provider.logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          // TAB 0: SHOPS APPROVAL
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.shops.length,
            itemBuilder: (context, index) {
              final s = provider.shops[index];
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text(s.name),
                  subtitle: Text('${s.address} · ${s.approved ? 'Approuvé' : 'En attente'}'),
                  trailing: ElevatedButton(
                    onPressed: () => provider.setShopApproved(s.id, !s.approved),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: s.approved ? Colors.red.shade700 : const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(s.approved ? 'Refuser' : 'Approuver'),
                  ),
                ),
              );
            },
          ),

          // TAB 1: USERS
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.adminUsers.length,
            itemBuilder: (context, index) {
              final u = provider.adminUsers[index];
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text('${u.name} (${u.role})'),
                  subtitle: Text('${u.email} · ${u.blocked ? 'Bloqué' : 'Actif'}'),
                  trailing: u.role == 'admin'
                      ? null
                      : TextButton(
                          onPressed: () => provider.toggleUserBlocked(u.uid, !u.blocked),
                          child: Text(u.blocked ? 'Débloquer' : 'Bloquer'),
                        ),
                ),
              );
            },
          ),

          // TAB 2: OFFERS & STATS
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Statistiques globales', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Utilisateurs : ${provider.adminUsers.length}'),
                      Text('Commerces : ${provider.shops.length}'),
                      Text('Offres : ${provider.offers.length}'),
                      Text('Commandes : ${provider.orders.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...provider.offers.map(
                (o) => Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(o.title),
                    subtitle: Text('${o.price.toStringAsFixed(2)} DT · Qté ${o.quantity}'),
                    trailing: IconButton(
                      onPressed: () => provider.deleteOffer(o.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (idx) => setState(() => _tab = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store), label: 'Commerces'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Utilisateurs'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Supervision'),
        ],
      ),
    );
  }
}
