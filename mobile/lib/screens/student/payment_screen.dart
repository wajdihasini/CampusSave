import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../repositories/payment_repository.dart';
import '../../utils/formatters.dart';
import '../../widgets/neo_widgets.dart';
import '../../widgets/state_views.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;
  const PaymentScreen({super.key, required this.order});
  @override State<PaymentScreen> createState() => _State();
}
class _State extends State<PaymentScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _pay() async {
    setState(() { _busy = true; _error = null; });
    final nav = Navigator.of(context);
    final msg = ScaffoldMessenger.of(context);
    try {
      final result = await PaymentRepository().pay(widget.order);
      if (!mounted) return;
      if (result.confirmed) {
        nav.pop(true); // back to orders; caller refetches to get qrToken
      } else if (result.payUrl != null) {
        // Konnect mode: show URL (integrate url_launcher to open in browser).
        setState(() => _error =
            'Open in browser:\n${result.payUrl}\n\nThen return here and refresh orders.');
      }
    } on PaymentException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        NeoCard(color: AppColors.cardYellow, padding: const EdgeInsets.all(16),
          child: const Row(children: [
            Icon(Icons.info_outline),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Make sure the backend is running with PAYMENT_PROVIDER=mock '
              'in .env to enable instant payment confirmation.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
          ])),
        const SizedBox(height: 20),
        NeoCard(padding: const EdgeInsets.all(18), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Order Summary',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 14),
          _row('Item',     o.title),
          _row('Quantity', '${o.quantity}'),
          if (o.expiresAt != null)
            _row('Expires', fTime(o.expiresAt!)),
          const Divider(height: 24, thickness: 1.5, color: AppColors.black),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text(fPrice(o.total),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ]),
        ])),
        if (_error != null) ...[
          const SizedBox(height: 14),
          NeoCard(color: const Color(0xFFFFE5E5), padding: const EdgeInsets.all(14),
            child: Text(_error!,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700))),
        ],
        const SizedBox(height: 24),
        NeoButton(label: 'Pay now', icon: Icons.payment,
            onPressed: _busy ? null : _pay, isLoading: _busy),
      ]),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
        Flexible(child: Text(v, textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700))),
      ]));
}
