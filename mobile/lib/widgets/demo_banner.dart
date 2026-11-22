import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.yellow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: const Row(
        children: [
          Icon(Icons.science_outlined, size: 16, color: AppColors.black),
          SizedBox(width: 8),
          Text(
            'DEMO MODE — not connected to server',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
