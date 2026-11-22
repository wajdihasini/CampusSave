import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../repositories/order_repository.dart';
import '../../utils/formatters.dart';
import '../../widgets/neo_widgets.dart';
import '../../widgets/state_views.dart';

class MerchantOrdersTab extends StatefulWidget {
  final String merchantId;
  const MerchantOrdersTab({super.key, required this.merchantId});
  @override State<MerchantOrdersTab> createState() => _State();
}
class _State extends State<MerchantOrdersTab> {
  final _repo = OrderRepository();
  late Future<List<Order>> _fut;

  @override void initState() { super.initState(); _load(); }
  void _load() {
    _fut = _repo.fetchMine();
    setState(() {});
  }

  Future<void> _validateQr(Order order) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Validate QR Code'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Ask the student to show their QR. Enter the token:'),
        const SizedBox(height: 12),
        TextField(controller: ctrl, maxLength: 32,
          decoration: const InputDecoration(
              labelText: 'QR Token', prefixIcon: Icon(Icons.qr_code))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Validate')),
      ]));
    if (ok != true || ctrl.text.trim().isEmpty) return;
    try {
      // POST /api/orders/validate { token }
      final result = await _repo.validateQr(ctrl.text.trim());
      if (!mounted) return;
      final points = result['points'] ?? 0;
      final title  = result['title']  ?? order.title;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('"$title" collected! +$points EcoPoints.'),
        backgroundColor: AppColors.green));
      _load();
    } on OrderException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: _fut,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError)
          return ErrorView(message: snap.error.toString(), onRetry: _load);
        final orders = snap.data ?? [];
        if (orders.isEmpty)
          return const EmptyView(
            message: 'No orders yet.',
            icon: Icons.inbox);
        return RefreshIndicator(
          onRefresh: () async => _load(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final o   = orders[i];
              Color col;
              switch (o.status) {
                case OrderStatus.pendingPayment: col = Colors.orange; break;
                case OrderStatus.paid:           col = AppColors.green; break;
                case OrderStatus.collected:      col = Colors.grey; break;
                default:                         col = AppColors.red;
              }
              return NeoCard(padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(child: Text(o.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                    NeoTag(label: o.status.label,
                        color: col.withAlpha(35), textColor: col),
                  ]),
                  const SizedBox(height: 6),
                  Text('x${o.quantity}  •  ${fPrice(o.total)}  •  ${fDate(o.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  if (o.studentName.isNotEmpty)
                    Text('Student: ${o.studentName}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  if (o.status == OrderStatus.paid) ...[
                    const SizedBox(height: 10),
                    NeoButton(
                      label: 'Validate QR code',
                      icon: Icons.qr_code_scanner,
                      color: AppColors.teal,
                      onPressed: () => _validateQr(o)),
                  ],
                ]));
            }));
      });
  }
}
