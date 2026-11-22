import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/offer.dart';
import 'package:mobile/utils/offer_filter.dart';

Offer _offer(
  String id,
  String title,
  String shop,
  String category,
  double original,
  double price,
) {
  return Offer(
    id: id,
    title: title,
    description: '',
    shopName: shop,
    shopId: 'test-shop',
    category: category,
    originalPrice: original,
    price: price,
    quantity: 5,
    pickupFrom: '12:00',
    pickupTo: '13:00',
  );
}

void main() {
  final offers = [
    _offer('1', 'Chicken sandwich', 'Cafe A', 'Meals', 8, 4),
    _offer('2', 'Croissant', 'Bakery B', 'Bakery', 6, 5),
    _offer('3', 'Iced coffee', 'Cafe A', 'Drinks', 5, 1),
  ];

  test('search matches title, shop and category', () {
    expect(filterOffers(offers, query: 'chicken').length, 1);
    expect(filterOffers(offers, query: 'cafe a').length, 2);
    expect(filterOffers(offers, query: 'bakery').length, 1);
    expect(filterOffers(offers, query: 'zzz'), isEmpty);
  });

  test('filters by category and max price', () {
    expect(filterOffers(offers, category: 'Drinks').length, 1);
    expect(filterOffers(offers, maxPrice: 4).length, 2);
  });

  test('sorts by price and discount', () {
    final byPrice = filterOffers(offers, sort: OfferSort.priceLow);
    expect(byPrice.first.id, '3');
    final byDiscount = filterOffers(offers, sort: OfferSort.discount);
    expect(byDiscount.first.id, '3'); // 80% de réduction
  });

  test('discountPercent is rounded', () {
    expect(offers[0].discountPercent, 50);
    expect(offers[1].discountPercent, 17);
  });
}
