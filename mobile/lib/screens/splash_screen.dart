import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/geometric_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GeometricBackground(
        backgroundColor: AppColors.green,
        patternColor: Colors.white.withAlpha(30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo box
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(color: AppColors.black, offset: Offset(6, 6), blurRadius: 0),
                  ],
                ),
                child: const Icon(Icons.eco, size: 60, color: AppColors.black),
              ),
              const SizedBox(height: 28),
              // Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.black, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: AppColors.black, offset: Offset(4, 4), blurRadius: 0),
                  ],
                ),
                child: const Text(
                  'CAMPUS\nSAVE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.black, width: 1.5),
                ),
                child: const Text(
                  'Fight Food Waste on Campus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
