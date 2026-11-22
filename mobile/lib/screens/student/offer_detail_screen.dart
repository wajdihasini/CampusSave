import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/offer.dart';
import '../../models/order.dart';
import '../../repositories/order_repository.dart';
import '../../utils/formatters.dart';
import '../../widgets/neo_widgets.dart';

class OfferDetailScreen extends StatefulWidget {
  final Offer offer;
  final String studentId;
  const OfferDetailScreen({super.key, required this.offer, required this.studentId});
  @override State<OfferDetailScreen> createState() => _State();
}
class _State extends State<OfferDetailScreen> {
  int _qty = 1;
  bool _busy = false;

  Future<void> _reserve() async {
    final msg = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final repo = OrderRepository();
      final id   = await repo.create(
          offerId: widget.offer.id, quantity: _qty);
      // Backend returns only the id; refetch to get the full Order.
      final order = await repo.findById(id);
      if (!mounted) return;
      nav.pop(order ?? Order(
        id: id, offerId: widget.offer.id,
        title: widget.offer.title, shopId: widget.offer.shopId,
        quantity: _qty, total: widget.offer.price * _qty,
        originalTotal: widget.offer.originalPrice * _qty,
        createdAt: DateTime.now(),
        status: OrderStatus.pendingPayment,
      ));
    } on OrderException catch (e) {
      msg.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.offer;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Offer Details')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Hero
        NeoCard(color: AppColors.black, padding: EdgeInsets.zero,
          child: SizedBox(height: 160, child: Stack(children: [
            Center(child: Icon(categoryIcon(o.category),
                size: 80, color: Colors.white.withAlpha(55))),
            Positioned(top: 16, right: 16,
              child: NeoTag(label: '-${o.discountPercent}%', color: AppColors.yellow)),
            Positioned(bottom: 12, left: 14, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.title, style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w900, fontSize: 20)),
              Text(o.shopName, style: const TextStyle(
                  color: Colors.white70, fontSize: 13)),
            ])),
          ]))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: NeoCard(color: AppColors.cardYellow,
            padding: const EdgeInsets.all(14), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Price', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(fPrice(o.price), style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900)),
              Text(fPrice(o.originalPrice), style: const TextStyle(
                  fontSize: 12, color: Colors.black38,
                  decoration: TextDecoration.lineThrough)),
            ]))),
          const SizedBox(width: 10),
          Expanded(child: NeoCard(color: AppColors.cardGreen,
            padding: const EdgeInsets.all(14), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Available', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(o.soldOut ? 'Sold out' : '${o.quantity} units',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                    color: o.soldOut ? AppColors.red : AppColors.black)),
            ]))),
        ]),
        const SizedBox(height: 10),
        NeoCard(color: AppColors.cardOrange, padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.schedule),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pickup', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: Colors.black54)),
              Text(fPickup(o.pickupFrom, o.pickupTo),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ]),
          ])),
        if (o.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          NeoCard(padding: const EdgeInsets.all(14), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(o.description, style: const TextStyle(height: 1.4)),
          ])),
        ],
        if (!o.soldOut) ...[
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Quantity', style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 16)),
            Row(children: [
              NeoOutlineButton(label: '−',
                onPressed: _qty > 1 && !_busy
                    ? () => setState(() => _qty--) : null),
              Container(width: 56, height: 48,
                decoration: const BoxDecoration(border: Border.symmetric(
                    horizontal: BorderSide(color: AppColors.black, width: 2))),
                child: Center(child: Text('$_qty',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)))),
              NeoOutlineButton(label: '+',
                onPressed: _qty < o.quantity && !_busy
                    ? () => setState(() => _qty++) : null),
            ]),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(fPrice(o.price * _qty),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ]),
          const SizedBox(height: 20),
        ],
        NeoButton(
          label: o.soldOut ? 'Sold out' : 'Reserve now',
          icon:  o.soldOut ? null : Icons.shopping_bag_outlined,
          color: o.soldOut ? Colors.grey.shade300 : AppColors.yellow,
          onPressed: o.soldOut || _busy ? null : _reserve,
          isLoading: _busy,
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
