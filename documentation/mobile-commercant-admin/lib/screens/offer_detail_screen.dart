import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class OfferDetailScreen extends StatefulWidget {
  final Offer offer;
  final Shop? shop;

  const OfferDetailScreen({
    super.key,
    required this.offer,
    required this.shop,
  });

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  int _quantity = 1;
  bool _busy = false;
  String? _error;

  Future<void> _reserveAndPay() async {
    final provider = context.read<AppProvider>();
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final order = await provider.reserveOffer(widget.offer.id, _quantity);
      final init = await provider.initKonnectPayment(order.id);
      final paymentRef = init['paymentRef'].toString();

      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Konnect Sandbox (Test)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Commande : ${order.id}'),
              const SizedBox(height: 6),
              Text('Référence : $paymentRef'),
              const SizedBox(height: 6),
              Text('Montant : ${order.total.toStringAsFixed(2)} DT',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Payer plus tard'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer le paiement test'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final paidOrder = await provider.confirmKonnectPayment(order.id, paymentRef);
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('QR Code de retrait'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (paidOrder.qrToken != null)
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: QrImageView(data: paidOrder.qrToken!, version: QrVersions.auto),
                  ),
                const SizedBox(height: 12),
                SelectableText(
                  paidOrder.qrToken ?? '',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final shop = widget.shop;
    final total = offer.price * _quantity;
    final outOfStock = offer.quantity <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(offer.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      backgroundColor: const Color(0xFFFAFAF9),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE7E5E4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${shop?.name ?? 'Commerce'} · ${offer.category}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (shop != null)
                    Text(
                      'Adresse : ${shop.address} · Tél : ${shop.phone}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Créneau de retrait : ${offer.pickupFrom} - ${offer.pickupTo}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Prix réduit', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          Text(
                            '${offer.price.toStringAsFixed(2)} DT',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          Text(
                            'Initial : ${offer.originalPrice.toStringAsFixed(2)} DT',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1 && !outOfStock
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: _quantity < offer.quantity && !outOfStock
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _busy || outOfStock ? null : _reserveAndPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                outOfStock
                    ? 'Offre épuisée'
                    : _busy
                        ? 'Traitement...'
                        : 'Réserver et payer ${total.toStringAsFixed(2)} DT',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
