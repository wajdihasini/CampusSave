import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../repositories/order_repository.dart';
import '../../utils/formatters.dart';
import '../../widgets/neo_widgets.dart';
import '../../widgets/state_views.dart';
import 'order_confirmation_screen.dart';
import 'payment_screen.dart';

class OrdersTab extends StatefulWidget {
  final int    refreshSignal;
  final String studentId;
  const OrdersTab({super.key, this.refreshSignal = 0, required this.studentId});
  @override State<OrdersTab> createState() => _State();
}
class _State extends State<OrdersTab> {
  final _repo = OrderRepository();
  late Future<List<Order>> _fut;

  @override void initState() { super.initState(); _load(); }
  @override void didUpdateWidget(covariant OrdersTab old) {
    super.didUpdateWidget(old);
    if (old.refreshSignal != widget.refreshSignal) _load();
  }
  void _load() {
    _fut = _repo.fetchMine();
    setState(() {});
  }

  Future<void> _pay(Order order) async {
    final paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => PaymentScreen(order: order)));
    if (paid != true || !mounted) return;
    _load();
    // Refetch to get qrToken, then show confirmation.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final updated = await _repo.findById(order.id);
    if (updated != null && mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: updated)));
    }
    if (mounted) _load();
  }

  Future<void> _cancel(Order order) async {
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel reservation'),
        content: Text('Cancel "${order.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel it',
                  style: TextStyle(color: Colors.red))),
        ]));
    if (ok != true) return;
    try {
      await _repo.cancel(order.id);
    } on OrderException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
    if (mounted) _load();
  }

  void _showQr(Order order) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OrderConfirmationScreen(order: order)));

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
            message: 'No orders yet.\nReserve an offer to get started!',
            icon: Icons.receipt_long);
        return RefreshIndicator(
          onRefresh: () async => _load(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderCard(
              order: orders[i],
              onPay:    () => _pay(orders[i]),
              onCancel: () => _cancel(orders[i]),
              onShowQr: () => _showQr(orders[i]))));
      });
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onPay, onCancel, onShowQr;
  const _OrderCard({required this.order, required this.onPay,
      required this.onCancel, required this.onShowQr});

  Color _col(BuildContext ctx) {
    switch (order.status) {
      case OrderStatus.pendingPayment: return Colors.orange;
      case OrderStatus.paid:           return AppColors.green;
      case OrderStatus.collected:      return Colors.grey;
      default:                         return Theme.of(ctx).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final col      = _col(context);
    final pending  = order.status == OrderStatus.pendingPayment;
    final paid     = order.status == OrderStatus.paid;

    return NeoCard(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(order.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
          NeoTag(label: order.status.label,
              color: col.withAlpha(40), textColor: col),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Text('x${order.quantity}  •  ${fPrice(order.total)}',
              style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(fDate(order.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.black38)),
        ]),
        if (pending || paid) ...[
          const SizedBox(height: 10),
          Row(children: [
            if (pending) ...[
              Expanded(child: NeoButton(label: 'Pay now', icon: Icons.payment,
                  onPressed: onPay)),
              const SizedBox(width: 10),
              NeoOutlineButton(label: 'Cancel',
                  borderColor: AppColors.red, textColor: AppColors.red,
                  onPressed: onCancel),
            ],
            if (paid)
              Expanded(child: NeoButton(
                  label: 'Show QR code', icon: Icons.qr_code,
                  color: AppColors.teal, onPressed: onShowQr)),
          ]),
        ],
      ]));
  }
}
