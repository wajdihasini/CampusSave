import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/offer_card.dart';
import 'offer_detail_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _tab = 0;
  final _searchCtrl = TextEditingController();
  final List<String> _categories = const [
    'Toutes',
    'Viennoiserie',
    'Sandwichs',
    'Salade',
    'Plats chauds',
    'Panier Surprise',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _payReservedOrder(CampusOrder order) async {
    final provider = context.read<AppProvider>();
    try {
      final init = await provider.initKonnectPayment(order.id);
      final paymentRef = init['paymentRef'].toString();
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Paiement Konnect Sandbox'),
          content: Text('Confirmer le paiement de ${order.total.toStringAsFixed(2)} DT (Réf: $paymentRef) ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
      if (ok == true) {
        await provider.confirmKonnectPayment(order.id, paymentRef);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showQrModal(CampusOrder order) {
    if (order.qrToken == null) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(order.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(data: order.qrToken!, version: QrVersions.auto),
            ),
            const SizedBox(height: 10),
            SelectableText(order.qrToken!, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final shopsMap = provider.shopsById;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      appBar: AppBar(
        title: const Text('CampusSave', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            onPressed: provider.refreshForCurrentRole,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
          IconButton(
            onPressed: provider.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          // TAB 0: OFFRES & FILTRES
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Rechercher croissant, salade, sandwich...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (v) => provider.setFilters(search: v),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final selected = provider.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => provider.setFilters(category: cat),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: provider.selectedShopId,
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Tous les commerces')),
                          ...provider.shops.map(
                            (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                          ),
                        ],
                        onChanged: (v) => provider.setFilters(shopId: v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<double?>(
                        value: provider.maxPrice,
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tous prix')),
                          DropdownMenuItem(value: 3.0, child: Text('<= 3.00 DT')),
                          DropdownMenuItem(value: 5.0, child: Text('<= 5.00 DT')),
                          DropdownMenuItem(value: 8.0, child: Text('<= 8.00 DT')),
                        ],
                        onChanged: (v) => provider.setFilters(priceLimit: v),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.loadCatalog,
                  child: provider.offers.isEmpty
                      ? const Center(child: Text('Aucune offre disponible pour ces critères.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.offers.length,
                          itemBuilder: (context, index) {
                            final offer = provider.offers[index];
                            final shop = shopsMap[offer.shopId];
                            return OfferCard(
                              offer: offer,
                              shop: shop,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OfferDetailScreen(offer: offer, shop: shop),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),

          // TAB 1: MES COMMANDES
          RefreshIndicator(
            onRefresh: provider.loadMyOrders,
            child: provider.orders.isEmpty
                ? const Center(child: Text('Vous n\'avez pas encore passé de commande.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.orders.length,
                    itemBuilder: (context, index) {
                      final ord = provider.orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${ord.title} (×${ord.quantity})',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('Total : ${ord.total.toStringAsFixed(2)} DT · Statut : ${ord.status}'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (ord.status == 'reserved') ...[
                                    ElevatedButton(
                                      onPressed: () => _payReservedOrder(ord),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F766E),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Payer Konnect'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => provider.cancelOrder(ord.id),
                                      child: const Text('Annuler'),
                                    ),
                                  ],
                                  if (ord.status == 'paid' && ord.qrToken != null)
                                    ElevatedButton.icon(
                                      onPressed: () => _showQrModal(ord),
                                      icon: const Icon(Icons.qr_code),
                                      label: const Text('Afficher QR Code'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F172A),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // TAB 2: TABLEAU DE BORD ÉTUDIANT
          _StudentStatsTab(orders: provider.orders, user: provider.user),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (idx) {
          setState(() => _tab = idx);
          if (idx == 1) provider.loadMyOrders();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Offres'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Commandes'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Tableau de bord'),
        ],
      ),
    );
  }
}

class _StudentStatsTab extends StatelessWidget {
  final List<CampusOrder> orders;
  final AppUser? user;

  const _StudentStatsTab({required this.orders, required this.user});

  @override
  Widget build(BuildContext context) {
    final confirmed = orders.where((o) => o.status == 'paid' || o.status == 'collected').toList();
    final portions = confirmed.fold<int>(0, (sum, o) => sum + o.quantity);
    final savedDt = confirmed.fold<double>(0, (sum, o) => sum + (o.originalTotal - o.total));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Bonjour ${user?.name ?? ''}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(user?.email ?? '', style: const TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 20),
        _StatBox(label: 'Commandes totales', value: '${orders.length}'),
        _StatBox(label: 'Portions alimentaires sauvées', value: '$portions'),
        _StatBox(label: 'Économies réalisées', value: '${savedDt.toStringAsFixed(2)} DT'),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E5E4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
          ),
        ],
      ),
    );
  }
}
