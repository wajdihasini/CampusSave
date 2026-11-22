import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/models.dart';

class ApiService {
  Future<Map<String, String>> _headers(String? idToken) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (idToken != null && idToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    return headers;
  }

  dynamic _parseResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final msg = data is Map<String, dynamic> ? (data['error'] ?? 'Erreur serveur') : 'Erreur serveur';
      throw Exception(msg);
    }
    return data;
  }

  // SHOPS
  Future<List<Shop>> fetchShops({bool all = false}) async {
    final res = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/shops${all ? '?all=true' : ''}'));
    final data = _parseResponse(res) as Map<String, dynamic>;
    final list = data['shops'] as List<dynamic>;
    return list.map((e) => Shop.fromMap(e['id'].toString(), e as Map<String, dynamic>)).toList();
  }

  Future<Shop> createOrUpdateShop(String idToken, Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/shops'),
      headers: await _headers(idToken),
      body: jsonEncode(payload),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    final shop = data['shop'] as Map<String, dynamic>;
    return Shop.fromMap(shop['id'].toString(), shop);
  }

  // OFFERS
  Future<List<Offer>> fetchOffers({
    String search = '',
    String category = 'Toutes',
    String shopId = '',
    double? maxPrice,
    bool includeAll = false,
  }) async {
    final params = <String, String>{};
    if (search.isNotEmpty) params['search'] = search;
    if (category != 'Toutes') params['category'] = category;
    if (shopId.isNotEmpty) params['shopId'] = shopId;
    if (maxPrice != null && maxPrice > 0) params['maxPrice'] = maxPrice.toString();
    if (includeAll) params['includeAll'] = 'true';

    final uri = Uri.parse('${AppConfig.apiBaseUrl}/offers').replace(queryParameters: params);
    final res = await http.get(uri);
    final data = _parseResponse(res) as Map<String, dynamic>;
    final list = data['offers'] as List<dynamic>;
    return list.map((e) => Offer.fromMap(e['id'].toString(), e as Map<String, dynamic>)).toList();
  }

  Future<Offer> createOffer(String idToken, Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/offers'),
      headers: await _headers(idToken),
      body: jsonEncode(payload),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    final offer = data['offer'] as Map<String, dynamic>;
    return Offer.fromMap(offer['id'].toString(), offer);
  }

  Future<void> updateOffer(String idToken, String offerId, Map<String, dynamic> updates) async {
    final res = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/offers/$offerId'),
      headers: await _headers(idToken),
      body: jsonEncode(updates),
    );
    _parseResponse(res);
  }

  Future<void> deleteOffer(String idToken, String offerId) async {
    final res = await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/offers/$offerId'),
      headers: await _headers(idToken),
    );
    _parseResponse(res);
  }

  // ORDERS & KONNECT
  Future<CampusOrder> reserveOrder(String idToken, String offerId, int quantity) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/orders/reserve'),
      headers: await _headers(idToken),
      body: jsonEncode({'offerId': offerId, 'quantity': quantity}),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    final ord = data['order'] as Map<String, dynamic>;
    return CampusOrder.fromMap(ord['id'].toString(), ord);
  }

  Future<void> cancelOrder(String idToken, String orderId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/orders/$orderId/cancel'),
      headers: await _headers(idToken),
    );
    _parseResponse(res);
  }

  Future<Map<String, dynamic>> initKonnectPayment(String idToken, String orderId) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/payments/konnect/init'),
      headers: await _headers(idToken),
      body: jsonEncode({'orderId': orderId}),
    );
    return _parseResponse(res) as Map<String, dynamic>;
  }

  Future<CampusOrder> verifyKonnectPayment(String idToken, String orderId, String paymentRef) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/payments/konnect/verify'),
      headers: await _headers(idToken),
      body: jsonEncode({
        'orderId': orderId,
        'paymentRef': paymentRef,
        'sandboxConfirmed': true,
      }),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    final ord = data['order'] as Map<String, dynamic>;
    return CampusOrder.fromMap(ord['id'].toString(), ord);
  }

  Future<List<CampusOrder>> fetchMyOrders(String idToken) async {
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/orders/my'),
      headers: await _headers(idToken),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    final list = data['orders'] as List<dynamic>;
    return list.map((e) => CampusOrder.fromMap(e['id'].toString(), e as Map<String, dynamic>)).toList();
  }

  Future<List<CampusOrder>> fetchMerchantOrders(String idToken) async {
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/orders/merchant'),
      headers: await _headers(idToken),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    final list = data['orders'] as List<dynamic>;
    return list.map((e) => CampusOrder.fromMap(e['id'].toString(), e as Map<String, dynamic>)).toList();
  }

  Future<String> validateQrCode(String idToken, String qrToken) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/orders/validate-qr'),
      headers: await _headers(idToken),
      body: jsonEncode({'qrToken': qrToken}),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    return (data['message'] ?? 'Récupération validée').toString();
  }

  // ADMIN
  Future<List<AppUser>> fetchAllUsers(String idToken) async {
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/admin/users'),
      headers: await _headers(idToken),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    final list = data['users'] as List<dynamic>;
    return list.map((e) => AppUser.fromMap(e['id'].toString(), e as Map<String, dynamic>)).toList();
  }

  Future<void> setUserBlocked(String idToken, String userId, bool blocked) async {
    final res = await http.patch(
      Uri.parse('${AppConfig.apiBaseUrl}/admin/users/$userId/block'),
      headers: await _headers(idToken),
      body: jsonEncode({'blocked': blocked}),
    );
    _parseResponse(res);
  }

  Future<void> setShopApproved(String idToken, String shopId, bool approved) async {
    final res = await http.patch(
      Uri.parse('${AppConfig.apiBaseUrl}/admin/shops/$shopId/approve'),
      headers: await _headers(idToken),
      body: jsonEncode({'approved': approved}),
    );
    _parseResponse(res);
  }

  Future<List<CampusOrder>> fetchAllOrders(String idToken) async {
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/admin/orders'),
      headers: await _headers(idToken),
    );
    final data = _parseResponse(res) as Map<String, dynamic>;
    final list = data['orders'] as List<dynamic>;
    return list.map((e) => CampusOrder.fromMap(e['id'].toString(), e as Map<String, dynamic>)).toList();
  }
}
