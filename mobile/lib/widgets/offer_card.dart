import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/offer.dart';
import '../utils/formatters.dart';
import 'neo_widgets.dart';

final _cardColors = [
  AppColors.cardYellow,
  AppColors.cardGreen,
  AppColors.cardOrange,
  AppColors.cardBlue,
];

Color _colorForOffer(Offer o) =>
    _cardColors[o.id.hashCode.abs() % _cardColors.length];

class OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onTap;
  const OfferCard({super.key, required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: _colorForOffer(offer),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 72,
          decoration: const BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 20),
            Icon(categoryIcon(offer.category), color: Colors.white, size: 28),
            const SizedBox(height: 8),
            NeoTag(label: '-${offer.discountPercent}%', color: AppColors.yellow),
            const SizedBox(height: 20),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(offer.title,
                    style: const TextStyle(fontWeight: FontWeight.w900,
                        fontSize: 15, color: AppColors.black),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (offer.soldOut)
                  NeoTag(label: 'SOLD OUT',
                      color: AppColors.red, textColor: Colors.white),
              ]),
              const SizedBox(height: 2),
              Text(offer.shopName,   // ← was merchantName
                style: const TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 12, color: Colors.black54),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                Text(fPrice(offer.price),   // ← was discountedPrice
                  style: const TextStyle(fontWeight: FontWeight.w900,
                      fontSize: 17, color: AppColors.black)),
                const SizedBox(width: 8),
                Text(fPrice(offer.originalPrice),
                  style: const TextStyle(fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.black38)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.schedule, size: 13, color: Colors.black54),
                const SizedBox(width: 4),
                Text(fPickup(offer.pickupFrom, offer.pickupTo),   // ← was pickupStart/End
                  style: const TextStyle(fontSize: 12,
                      color: Colors.black54, fontWeight: FontWeight.w500)),
                const Spacer(),
                if (!offer.soldOut)
                  Text('${offer.quantity} left',
                    style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w700, color: AppColors.green)),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}
