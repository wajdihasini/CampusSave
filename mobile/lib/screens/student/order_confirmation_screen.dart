import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../utils/formatters.dart';
import '../../widgets/neo_widgets.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // qrToken is the 32-char hex token validated by POST /api/orders/validate.
    // Falls back to order.id if somehow absent.
    final qrData = (order.qrToken?.isNotEmpty == true)
        ? order.qrToken!
        : order.id;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Order Confirmed')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        NeoCard(color: const Color(0xFFE0FFE0), padding: const EdgeInsets.all(20),
          child: const Column(children: [
            Icon(Icons.check_circle, color: AppColors.green, size: 56),
            SizedBox(height: 8),
            Text('Payment Confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            SizedBox(height: 4),
            Text('Show this QR code to the merchant on pickup',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54)),
          ])),
        const SizedBox(height: 16),
        NeoCard(padding: const EdgeInsets.all(20), child: Column(children: [
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
          const SizedBox(height: 10),
          Text('${qrData.substring(0, 8).toUpperCase()}…',
            style: const TextStyle(fontFamily: 'monospace',
                fontSize: 12, color: Colors.grey)),
        ])),
        const SizedBox(height: 14),
        NeoCard(color: AppColors.cardBlue, padding: const EdgeInsets.all(16),
          child: Column(children: [
          _row('Item',  order.title),
          _row('Qty',   '${order.quantity}'),
          _row('Total', fPrice(order.total)),
        ])),
        const SizedBox(height: 20),
        NeoButton(label: 'Back to my orders',
            onPressed: () => Navigator.of(context).pop()),
      ]),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
      ]));
}
