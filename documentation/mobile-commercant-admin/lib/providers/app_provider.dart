import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? user;
  bool loading = false;
  String? error;

  List<Shop> shops = [];
  List<Offer> offers = [];
  List<CampusOrder> orders = [];
  List<AppUser> adminUsers = [];

  // Filtres Étudiant
  String searchQuery = '';
  String selectedCategory = 'Toutes';
  String selectedShopId = '';
  double? maxPrice;

  Map<String, Shop> get shopsById => {for (final s in shops) s.id: s};

  Shop? get myShop {
    if (user == null) return null;
    for (final s in shops) {
      if (s.ownerId == user!.uid) return s;
    }
    return null;
  }

  Future<void> restoreSession() async {
    final fbUser = _authService.currentFirebaseUser;
    if (fbUser == null) return;
    loading = true;
    notifyListeners();
    try {
      final profile = await _authService.fetchUserProfile(fbUser.uid);
      if (profile.blocked) {
        await _authService.signOut();
        user = null;
      } else {
        user = profile;
        await refreshForCurrentRole();
      }
    } catch (_) {
      user = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.signIn(email, password);
      await refreshForCurrentRole();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      await refreshForCurrentRole();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    user = null;
    offers = [];
    orders = [];
    shops = [];
    adminUsers = [];
    notifyListeners();
  }

  Future<void> refreshForCurrentRole() async {
    if (user == null) return;
    if (user!.role == 'student') {
      await Future.wait([loadCatalog(), loadMyOrders()]);
    } else if (user!.role == 'merchant') {
      await loadMerchantData();
    } else if (user!.role == 'admin') {
      await loadAdminData();
    }
  }

  Future<void> loadCatalog() async {
    try {
      // Lecture directe Firestore (ou via API Express)
      final shopsSnap = await _firestore.collection('shops').where('approved', isEqualTo: true).get();
      shops = shopsSnap.docs.map((d) => Shop.fromMap(d.id, d.data())).toList();
      final approvedIds = shops.map((s) => s.id).toSet();

      final offersSnap = await _firestore.collection('offers').get();
      offers = offersSnap.docs
          .map((d) => Offer.fromMap(d.id, d.data()))
          .where((o) {
            if (!approvedIds.contains(o.shopId)) return false;
            if (selectedCategory != 'Toutes' && o.category != selectedCategory) return false;
            if (selectedShopId.isNotEmpty && o.shopId != selectedShopId) return false;
            if (maxPrice != null && o.price > maxPrice!) return false;
            if (searchQuery.isNotEmpty) {
              final q = searchQuery.toLowerCase();
              if (!o.title.toLowerCase().contains(q) && !o.category.toLowerCase().contains(q)) {
                return false;
              }
            }
            return true;
          })
          .toList();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void setFilters({String? search, String? category, String? shopId, double? priceLimit}) {
    if (search != null) searchQuery = search;
    if (category != null) selectedCategory = category;
    if (shopId != null) selectedShopId = shopId;
    maxPrice = priceLimit;
    loadCatalog();
  }

  Future<void> loadMyOrders() async {
    final token = await _authService.getIdToken();
    if (token == null) return;
    try {
      orders = await _apiService.fetchMyOrders(token);
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<CampusOrder> reserveOffer(String offerId, int quantity) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    final order = await _apiService.reserveOrder(token, offerId, quantity);
    await loadCatalog();
    await loadMyOrders();
    return order;
  }

  Future<Map<String, dynamic>> initKonnectPayment(String orderId) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    return _apiService.initKonnectPayment(token, orderId);
  }

  Future<CampusOrder> confirmKonnectPayment(String orderId, String paymentRef) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    final paid = await _apiService.verifyKonnectPayment(token, orderId, paymentRef);
    await loadMyOrders();
    return paid;
  }

  Future<void> cancelOrder(String orderId) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    await _apiService.cancelOrder(token, orderId);
    await loadCatalog();
    await loadMyOrders();
  }

  // MERCHANT
  Future<void> loadMerchantData() async {
    final token = await _authService.getIdToken();
    if (token == null || user == null) return;
    shops = await _apiService.fetchShops(all: true);
    final shopId = myShop?.id;
    final allOffers = await _apiService.fetchOffers(includeAll: true);
    offers = shopId == null ? [] : allOffers.where((o) => o.shopId == shopId).toList();
    orders = await _apiService.fetchMerchantOrders(token);
    notifyListeners();
  }

  Future<void> saveShop(Map<String, dynamic> payload) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    await _apiService.createOrUpdateShop(token, payload);
    await loadMerchantData();
  }

  Future<void> createOffer(Map<String, dynamic> payload) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    await _apiService.createOffer(token, payload);
    await loadMerchantData();
  }

  Future<void> updateOfferQty(String offerId, int qty) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    await _apiService.updateOffer(token, offerId, {'quantity': qty < 0 ? 0 : qty});
    await loadMerchantData();
  }

  Future<void> deleteOffer(String offerId) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    await _apiService.deleteOffer(token, offerId);
    await refreshForCurrentRole();
  }

  Future<String> validateQr(String qrToken) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Session expirée.');
    final msg = await _apiService.validateQrCode(token, qrToken);
    await loadMerchantData();
    return msg;
  }

  // ADMIN
  Future<void> loadAdminData() async {
    final token = await _authService.getIdToken();
    if (token == null) return;
    final results = await Future.wait([
      _apiService.fetchAllUsers(token),
      _apiService.fetchShops(all: true),
      _apiService.fetchOffers(includeAll: true),
      _apiService.fetchAllOrders(token),
    ]);
    adminUsers = results[0] as List<AppUser>;
    shops = results[1] as List<Shop>;
    offers = results[2] as List<Offer>;
    orders = results[3] as List<CampusOrder>;
    notifyListeners();
  }

  Future<void> toggleUserBlocked(String userId, bool blocked) async {
    final token = await _authService.getIdToken();
    if (token == null) return;
    await _apiService.setUserBlocked(token, userId, blocked);
    await loadAdminData();
  }

  Future<void> setShopApproved(String shopId, bool approved) async {
    final token = await _authService.getIdToken();
    if (token == null) return;
    await _apiService.setShopApproved(token, shopId, approved);
    await loadAdminData();
  }
}
