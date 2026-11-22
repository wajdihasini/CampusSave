import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/repositories/order_repository.dart';
import 'package:mobile/services/api_service.dart';

void main() {
  test('creates an order using the backend order endpoint', () async {
    late http.Request captured;
    final api = ApiService(
      client: MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode({'id': 'order-123'}), 201);
      }),
      tokenProvider: () async => 'student-token',
    );
    final repository = OrderRepository(api: api);

    final id = await repository.create(offerId: 'offer-1', quantity: 2);

    expect(id, 'order-123');
    expect(captured.method, 'POST');
    expect(captured.url.path, '/api/orders');
    expect(jsonDecode(captured.body), {'offerId': 'offer-1', 'quantity': 2});
    expect(captured.headers['authorization'], 'Bearer student-token');
  });

  test('cancels an order through the backend endpoint', () async {
    late http.Request captured;
    final api = ApiService(
      client: MockClient((request) async {
        captured = request;
        return http.Response('{"ok":true}', 200);
      }),
      tokenProvider: () async => 'student-token',
    );
    final repository = OrderRepository(api: api);

    await repository.cancel('order-123');

    expect(captured.method, 'POST');
    expect(captured.url.path, '/api/orders/order-123/cancel');
  });

  test('converts backend errors into OrderException', () async {
    final api = ApiService(
      client: MockClient(
        (_) async => http.Response('{"error":"Stock insuffisant"}', 400),
      ),
      tokenProvider: () async => 'student-token',
    );
    final repository = OrderRepository(api: api);

    expect(
      repository.create(offerId: 'offer-1', quantity: 2),
      throwsA(isA<OrderException>()),
    );
  });
}
