import 'package:flutter/material.dart';
import '../../models/offer.dart';
import '../../models/order.dart';
import '../../repositories/offer_repository.dart';
import '../../utils/offer_filter.dart';
import '../../widgets/offer_card.dart';
import '../../widgets/state_views.dart';
import 'offer_detail_screen.dart';

class OffersTab extends StatefulWidget {
  final ValueChanged<Order>? onReserved;
  final String studentId;
  const OffersTab({super.key, this.onReserved, required this.studentId});
  @override State<OffersTab> createState() => _State();
}
class _State extends State<OffersTab> {
  static const double _smax = 20;
  final _repo = OfferRepository();
  late Future<List<Offer>> _fut;
  String _q = ''; String? _cat; double _mp = _smax;
  OfferSort _sort = OfferSort.relevance;

  @override void initState() { super.initState(); _load(); }

  void _load() {
    _fut = _repo.fetchAll(
        query: _q, category: _cat,
        maxPrice: _mp >= _smax ? null : _mp);
    setState(() {});
  }

  Future<void> _openOffer(Offer o) async {
    final order = await Navigator.of(context).push<Order>(
        MaterialPageRoute(builder: (_) =>
            OfferDetailScreen(offer: o, studentId: widget.studentId)));
    if (order == null || !mounted) return;
    _load();
    widget.onReserved?.call(order);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: TextField(
          onChanged: (v) { _q = v; _load(); },
          decoration: const InputDecoration(
            labelText: 'Search offers, shops...',
            prefixIcon: Icon(Icons.search)))),
      SizedBox(height: 48, child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          Padding(padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(label: const Text('All'),
              selected: _cat == null,
              onSelected: (_) { _cat = null; _load(); })),
          for (final cat in offerCategories)
            Padding(padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(cat),
                selected: _cat == cat,
                onSelected: (_) { _cat = cat; _load(); })),
        ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Text(_mp >= _smax ? 'Any price' : 'Up to ${_mp.round()} TND',
              style: const TextStyle(fontSize: 12)),
          Expanded(child: Slider(value: _mp, min: 1, max: _smax, divisions: 19,
            onChanged: (v) => setState(() => _mp = v),
            onChangeEnd: (_) => _load())),
          PopupMenuButton<OfferSort>(tooltip: 'Sort', icon: const Icon(Icons.sort),
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => [
              for (final s in OfferSort.values)
                CheckedPopupMenuItem(value: s, checked: _sort == s,
                  child: Text(s.name)),
            ]),
        ])),
      Expanded(child: FutureBuilder<List<Offer>>(
        future: _fut,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done)
            return const LoadingView();
          if (snap.hasError)
            return ErrorView(message: snap.error.toString(), onRetry: _load);
          final offers = filterOffers(snap.data ?? [], sort: _sort);
          if (offers.isEmpty)
            return const EmptyView(
              message: 'No offers match your search.',
              icon: Icons.search_off);
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  OfferCard(offer: offers[i], onTap: () => _openOffer(offers[i]))));
        })),
    ]);
  }
}
