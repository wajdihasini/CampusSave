import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  int _tab = 0;

  // Formulaire commerce
  final _shopNameCtrl = TextEditingController();
  final _shopAddrCtrl = TextEditingController();
  final _shopPhoneCtrl = TextEditingController();
  final _shopDescCtrl = TextEditingController();

  // Formulaire offre
  final _offerTitleCtrl = TextEditingController();
  final _offerCatCtrl = TextEditingController(text: 'Viennoiserie');
  final _offerOrigCtrl = TextEditingController(text: '5.0');
  final _offerPriceCtrl = TextEditingController(text: '2.5');
  final _offerQtyCtrl = TextEditingController(text: '5');
  final _offerFromCtrl = TextEditingController(text: '17:00');
  final _offerToCtrl = TextEditingController(text: '19:00');

  // Validation QR
  final _qrCtrl = TextEditingController();
  String? _qrMsg;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _shopAddrCtrl.dispose();
    _shopPhoneCtrl.dispose();
    _shopDescCtrl.dispose();
    _offerTitleCtrl.dispose();
    _offerCatCtrl.dispose();
    _offerOrigCtrl.dispose();
    _offerPriceCtrl.dispose();
    _offerQtyCtrl.dispose();
    _offerFromCtrl.dispose();
    _offerToCtrl.dispose();
    _qrCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    final provider = context.read<AppProvider>();
    try {
      await provider.saveShop({
        'name': _shopNameCtrl.text.trim(),
        'address': _shopAddrCtrl.text.trim(),
        'phone': _shopPhoneCtrl.text.trim(),
        'description': _shopDescCtrl.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commerce enregistré. En attente de validation admin.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _createOffer() async {
    final provider = context.read<AppProvider>();
    final shop = provider.myShop;
    if (shop == null) return;
    try {
      await provider.createOffer({
        'shopId': shop.id,
        'title': _offerTitleCtrl.text.trim(),
        'category': _offerCatCtrl.text.trim(),
        'originalPrice': double.tryParse(_offerOrigCtrl.text) ?? 5.0,
        'price': double.tryParse(_offerPriceCtrl.text) ?? 2.5,
        'quantity': int.tryParse(_offerQtyCtrl.text) ?? 1,
        'pickupFrom': _offerFromCtrl.text.trim(),
        'pickupTo': _offerToCtrl.text.trim(),
      });
      _offerTitleCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offre publiée.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _validateQr() async {
    final provider = context.read<AppProvider>();
    try {
      final msg = await provider.validateQr(_qrCtrl.text.trim());
      setState(() => _qrMsg = msg);
      _qrCtrl.clear();
    } catch (e) {
      setState(() => _qrMsg = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final shop = provider.myShop;
    final confirmedOrders = provider.orders.where((o) => o.status == 'paid' || o.status == 'collected').toList();
    final revenue = confirmedOrders.fold<double>(0, (s, o) => s + o.total);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      appBar: AppBar(
        title: const Text('Espace Commerçant', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(onPressed: provider.loadMerchantData, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: provider.logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          // TAB 0: OFFRES
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (shop == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Commencez par enregistrer votre commerce dans l\'onglet "Commerce".'),
                  ),
                )
              else if (!shop.approved)
                Card(
                  color: const Color(0xFFFFFBEB),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Votre établissement "${shop.name}" est en attente de validation par l\'administrateur.',
                      style: const TextStyle(color: Color(0xFF92400E)),
                    ),
                  ),
                )
              else ...[
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Nouvelle offre', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _offerTitleCtrl,
                          decoration: const InputDecoration(labelText: 'Titre', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _offerCatCtrl,
                          decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _offerOrigCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Prix initial', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _offerPriceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Prix réduit', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _offerQtyCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Qté', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _offerFromCtrl,
                                decoration: const InputDecoration(labelText: 'Début retrait', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _offerToCtrl,
                                decoration: const InputDecoration(labelText: 'Fin retrait', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _createOffer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Publier l\'offre'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...provider.offers.map(
                  (o) => Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(o.title),
                      subtitle: Text('${o.price.toStringAsFixed(2)} DT · Stock : ${o.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => provider.updateOfferQty(o.id, o.quantity - 1),
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            onPressed: () => provider.updateOfferQty(o.id, o.quantity + 1),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            onPressed: () => provider.deleteOffer(o.id),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // TAB 1: COMMANDES & VALIDATION QR
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Valider un QR Code étudiant',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _qrCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Code QR (CS-...)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _validateQr,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Valider la récupération (usage unique)'),
                      ),
                      if (_qrMsg != null) ...[
                        const SizedBox(height: 10),
                        Text(_qrMsg!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...provider.orders.map(
                (ord) => Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text('${ord.title} (×${ord.quantity})'),
                    subtitle: Text('${ord.studentName} · ${ord.total.toStringAsFixed(2)} DT'),
                    trailing: Text(ord.status, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),

          // TAB 2: MON COMMERCE & STATS
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white,
                child: ListTile(
                  title: const Text('Chiffre d\'affaires validé'),
                  trailing: Text(
                    '${revenue.toStringAsFixed(2)} DT',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        shop == null ? 'Enregistrer mon établissement' : 'Mon établissement (${shop.name})',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _shopNameCtrl..text = _shopNameCtrl.text.isEmpty ? (shop?.name ?? '') : _shopNameCtrl.text,
                        decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _shopAddrCtrl..text = _shopAddrCtrl.text.isEmpty ? (shop?.address ?? '') : _shopAddrCtrl.text,
                        decoration: const InputDecoration(labelText: 'Adresse', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _shopPhoneCtrl..text = _shopPhoneCtrl.text.isEmpty ? (shop?.phone ?? '') : _shopPhoneCtrl.text,
                        decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _shopDescCtrl..text = _shopDescCtrl.text.isEmpty ? (shop?.description ?? '') : _shopDescCtrl.text,
                        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saveShop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ],
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
          NavigationDestination(icon: Icon(Icons.local_offer), label: 'Offres'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Commandes & QR'),
          NavigationDestination(icon: Icon(Icons.store), label: 'Commerce'),
        ],
      ),
    );
  }
}
