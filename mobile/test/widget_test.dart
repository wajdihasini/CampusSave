import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/validators.dart';
import 'package:mobile/utils/offer_filter.dart';
import 'package:mobile/models/offer.dart';
import 'package:mobile/models/user_role.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('bad'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });
    test('password', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
    test('confirmPassword', () {
      expect(Validators.confirmPassword('x', 'y'), isNotNull);
      expect(Validators.confirmPassword('abc', 'abc'), isNull);
    });
  });

  group('UserRole', () {
    test('fromString round-trip', () {
      for (final r in UserRole.values) {
        expect(UserRole.fromString(r.name), r);
      }
    });
    test('fromString unknown returns null', () {
      expect(UserRole.fromString('unknown'), isNull);
    });
  });

  group('offerFilter', () {
    Offer make(
      String id,
      String title,
      String shop,
      String cat,
      double orig,
      double price,
    ) => Offer(
      id: id,
      shopId: 'mid',
      shopName: shop,
      title: title,
      description: '',
      category: cat,
      originalPrice: orig,
      price: price,
      quantity: 5,
      pickupFrom: '12:00',
      pickupTo: '14:00',
    );

    final offers = [
      make('1', 'Chicken sandwich', 'Cafe A', 'Meals', 8, 4),
      make('2', 'Croissant', 'Bakery B', 'Bakery', 6, 5),
      make('3', 'Iced coffee', 'Cafe A', 'Drinks', 5, 1),
    ];

    test('search matches title, shop, category', () {
      expect(filterOffers(offers, query: 'chicken').length, 1);
      expect(filterOffers(offers, query: 'cafe a').length, 2);
      expect(filterOffers(offers, query: 'bakery').length, 1);
      expect(filterOffers(offers, query: 'zzz'), isEmpty);
    });

    test('filters by category and maxPrice', () {
      expect(filterOffers(offers, category: 'Drinks').length, 1);
      expect(filterOffers(offers, maxPrice: 4).length, 2);
    });

    test('sorts correctly', () {
      final byPrice = filterOffers(offers, sort: OfferSort.priceLow);
      expect(byPrice.first.id, '3');
    });

    test('discountPercent', () {
      expect(offers[0].discountPercent, 50);
    });
  });
}
