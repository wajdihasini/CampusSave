import 'package:flutter/material.dart';
import '../models/models.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final Shop? shop;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.offer,
    required this.shop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = offer.quantity <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE7E5E4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: offer.photo.isNotEmpty
                  ? Image.network(
                      offer.photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _FallbackBanner(category: offer.category),
                    )
                  : _FallbackBanner(category: offer.category),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${shop?.name ?? 'Commerce partenaire'} · ${offer.category}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${offer.price.toStringAsFixed(2)} DT',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${offer.originalPrice.toStringAsFixed(2)} DT',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        outOfStock ? 'Épuisé' : '${offer.quantity} dispo.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: outOfStock ? const Color(0xFFB91C1C) : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Retrait : ${offer.pickupFrom} - ${offer.pickupTo} · -${offer.discountPercent}%',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  final String category;

  const _FallbackBanner({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F4),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 36, color: Color(0xFF0F766E)),
          const SizedBox(height: 6),
          Text(
            category,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}
