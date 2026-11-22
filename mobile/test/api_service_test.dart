import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/services/api_service.dart';

void main() {
  test('returns decoded JSON on success', () async {
    final api = ApiService(
      client: MockClient((_) async => http.Response('{"ok":true}', 200)),
      tokenProvider: () async => 'test-token',
    );

    final data = await api.get('/ping', auth: false);

    expect(data, isA<Map<String, dynamic>>());
    expect(data['ok'], isTrue);
  });

  test('sends query parameters and bearer token', () async {
    late http.Request captured;
    final api = ApiService(
      client: MockClient((request) async {
        captured = request;
        return http.Response('[]', 200);
      }),
      tokenProvider: () async => 'test-token',
    );

    await api.get('/api/offers', q: {'q': 'coffee & tea'});

    expect(captured.url.queryParameters['q'], 'coffee & tea');
    expect(captured.headers['authorization'], 'Bearer test-token');
  });

  test('throws ApiException with server message and status code', () async {
    final api = ApiService(
      client: MockClient(
        (_) async => http.Response('{"error":"Not found"}', 404),
      ),
      tokenProvider: () async => 'test-token',
    );

    expect(
      api.get('/missing', auth: false),
      throwsA(
        isA<ApiException>()
            .having((error) => error.message, 'message', 'Not found')
            .having((error) => error.statusCode, 'statusCode', 404),
      ),
    );
  });

  test('uses a generic message when the error body is not JSON', () async {
    final api = ApiService(
      client: MockClient((_) async => http.Response('oops', 500)),
      tokenProvider: () async => 'test-token',
    );

    expect(
      api.get('/boom', auth: false),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          500,
        ),
      ),
    );
  });

  test('rejects authenticated requests without a token', () async {
    final api = ApiService(
      client: MockClient((_) async => http.Response('{}', 200)),
      tokenProvider: () async => null,
    );

    expect(
      api.get('/private'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });
}
