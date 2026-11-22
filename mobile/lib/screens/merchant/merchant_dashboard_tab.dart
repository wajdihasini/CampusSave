import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../repositories/admin_repository.dart';
import '../../widgets/neo_widgets.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/state_views.dart';

class MerchantDashboardTab extends StatelessWidget {
  final String merchantId;
  const MerchantDashboardTab({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: AdminRepository().fetchStats(), // GET /api/stats (role=merchant)
      builder: (_, snap) {
        if (!snap.hasData && !snap.hasError) return const LoadingView();
        if (snap.hasError)
          return ErrorView(
            message: 'Could not load stats.\n${snap.error}',
            onRetry: () {});
        final d = snap.data!;
        final rev = (d['revenue'] as num?)?.toDouble() ?? 0.0;
        return ListView(padding: const EdgeInsets.all(16), children: [
          NeoCard(color: AppColors.black, padding: const EdgeInsets.all(16),
            child: const Row(children: [
              Icon(Icons.storefront, color: AppColors.yellow),
              SizedBox(width: 10),
              Text('My Dashboard', style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w900, fontSize: 16)),
            ])),
          const SizedBox(height: 16),
          GridView.count(crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
            children: [
              StatCard(label: 'Paid orders',
                  value: '${d['orders']     ?? 0}', icon: Icons.receipt_long,
                  color: AppColors.orange),
              StatCard(label: 'Revenue (TND)',
                  value: rev.toStringAsFixed(2), icon: Icons.payments,
                  color: AppColors.green),
              StatCard(label: 'To collect',
                  value: '${d['toCollect']   ?? 0}',
                  icon: Icons.check_circle_outline, color: AppColors.teal),
              StatCard(label: 'Meals saved',
                  value: '${d['mealsSaved']  ?? 0}', icon: Icons.eco,
                  color: AppColors.yellow),
            ]),
        ]);
      });
  }
}
