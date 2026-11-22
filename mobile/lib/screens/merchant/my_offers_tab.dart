import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/offer.dart';
import '../../repositories/offer_repository.dart';
import '../../utils/formatters.dart';
import '../../widgets/neo_widgets.dart';
import '../../widgets/state_views.dart';
import 'offer_form_screen.dart';

class MyOffersTab extends StatefulWidget {
  final String merchantId;
  const MyOffersTab({super.key, required this.merchantId});
  @override State<MyOffersTab> createState() => _State();
}
class _State extends State<MyOffersTab> {
  final _repo = OfferRepository();
  late Future<List<Offer>> _fut;

  @override void initState() { super.initState(); _load(); }
  void _load() {
    _fut = _repo.fetchForMerchant();
    setState(() {});
  }

  Future<void> _delete(Offer o) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete offer'),
      content: Text('Delete "${o.title}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red))),
      ]));
    if (ok != true) return;
    try { await _repo.deleteOffer(o.id); }
    catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) _load();
  }

  Future<void> _openForm({Offer? edit}) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) =>
            OfferFormScreen(merchantId: widget.merchantId, existing: edit)));
    if (saved == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Offer>>(
      future: _fut,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError)
          return ErrorView(message: snap.error.toString(), onRetry: _load);
        final offers = snap.data ?? [];
        return Column(children: [
          Padding(padding: const EdgeInsets.all(14),
            child: NeoButton(label: 'Create new offer', icon: Icons.add,
                onPressed: () => _openForm())),
          if (offers.isEmpty)
            const Expanded(child: EmptyView(
                message: 'No offers yet.', icon: Icons.add_box_outlined)),
          if (offers.isNotEmpty) Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: offers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final o = offers[i];
                  return NeoCard(padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Container(width: 52, height: 52,
                        decoration: BoxDecoration(color: AppColors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(categoryIcon(o.category),
                            color: Colors.white, size: 24)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${fPrice(o.price)}  •  ${o.quantity} left',
                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        Text('${o.pickupFrom} – ${o.pickupTo}',
                          style: const TextStyle(fontSize: 11, color: Colors.black38)),
                      ])),
                      PopupMenuButton(itemBuilder: (_) => [
                        PopupMenuItem(onTap: () => _openForm(edit: o),
                          child: const Row(children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8), Text('Edit')])),
                        PopupMenuItem(onTap: () => _delete(o),
                          child: const Row(children: [
                            Icon(Icons.delete_outlined, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red))])),
                      ]),
                    ]));
                }))),
        ]);
      });
  }
}
