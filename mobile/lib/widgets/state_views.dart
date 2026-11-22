import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(
      strokeWidth: 3,
      color: AppColors.black,
    ),
  );
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(16),
                border: const Border.fromBorderSide(
                  BorderSide(color: AppColors.black, width: 2.5),
                ),
                boxShadow: const [
                  BoxShadow(color: AppColors.black, offset: Offset(4, 4), blurRadius: 0),
                ],
              ),
              child: const Icon(Icons.error_outline, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.black),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardYellow,
                borderRadius: BorderRadius.circular(16),
                border: const Border.fromBorderSide(
                  BorderSide(color: AppColors.black, width: 2.5),
                ),
                boxShadow: const [
                  BoxShadow(color: AppColors.black, offset: Offset(4, 4), blurRadius: 0),
                ],
              ),
              child: Icon(icon, size: 48, color: AppColors.black),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
