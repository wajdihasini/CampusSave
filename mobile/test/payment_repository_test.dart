import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/repositories/payment_repository.dart';
import 'package:mobile/services/api_service.dart';

void main() {
  final order = Order(
    id: 'order-123',
    offerId: 'offer-1',
    title: 'Lunch box',
    shopId: 'shop-1',
    quantity: 1,
    total: 5,
    originalTotal: 8,
    createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
    status: OrderStatus.pendingPayment,
  );

  test('confirms payment when backend mock payment succeeds', () async {
    final api = ApiService(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/orders/order-123/mock-pay');
        return http.Response('{"ok":true}', 200);
      }),
      tokenProvider: () async => 'student-token',
    );
    final repository = PaymentRepository(api: api);

    final result = await repository.pay(order);

    expect(result.confirmed, isTrue);
    expect(result.payUrl, isNull);
  });

  test(
    'falls back to Konnect when mock payment route is unavailable',
    () async {
      var callCount = 0;
      final api = ApiService(
        client: MockClient((request) async {
          callCount++;
          if (request.url.path.endsWith('/mock-pay')) {
            return http.Response('{"error":"Not found"}', 404);
          }
          expect(request.url.path, '/api/orders/order-123/pay');
          return http.Response(
            '{"payUrl":"https://pay.example.test/session"}',
            200,
          );
        }),
        tokenProvider: () async => 'student-token',
      );
      final repository = PaymentRepository(api: api);

      final result = await repository.pay(order);

      expect(callCount, 2);
      expect(result.confirmed, isFalse);
      expect(result.payUrl, 'https://pay.example.test/session');
    },
  );

  test('propagates payment errors', () async {
    final api = ApiService(
      client: MockClient(
        (_) async => http.Response('{"error":"Order already cancelled"}', 400),
      ),
      tokenProvider: () async => 'student-token',
    );
    final repository = PaymentRepository(api: api);

    expect(repository.pay(order), throwsA(isA<PaymentException>()));
  });
}
