class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' | 'merchant' | 'admin'
  final bool blocked;
  final int createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.blocked,
    required this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      role: (data['role'] ?? 'student').toString(),
      blocked: data['blocked'] == true,
      createdAt: (data['createdAt'] as num? ?? 0).toInt(),
    );
  }
}

class Shop {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String phone;
  final String description;
  final bool approved;
  final int createdAt;

  Shop({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.approved,
    required this.createdAt,
  });

  factory Shop.fromMap(String id, Map<String, dynamic> data) {
    return Shop(
      id: id,
      ownerId: (data['ownerId'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      approved: data['approved'] == true,
      createdAt: (data['createdAt'] as num? ?? 0).toInt(),
    );
  }
}

class Offer {
  final String id;
  final String shopId;
  final String title;
  final String category;
  final double originalPrice;
  final double price;
  final int quantity;
  final String pickupFrom;
  final String pickupTo;
  final String photo;
  final int createdAt;

  Offer({
    required this.id,
    required this.shopId,
    required this.title,
    required this.category,
    required this.originalPrice,
    required this.price,
    required this.quantity,
    required this.pickupFrom,
    required this.pickupTo,
    required this.photo,
    required this.createdAt,
  });

  int get discountPercent {
    if (originalPrice <= 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  factory Offer.fromMap(String id, Map<String, dynamic> data) {
    return Offer(
      id: id,
      shopId: (data['shopId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      originalPrice: (data['originalPrice'] as num? ?? 0).toDouble(),
      price: (data['price'] as num? ?? 0).toDouble(),
      quantity: (data['quantity'] as num? ?? 0).toInt(),
      pickupFrom: (data['pickupFrom'] ?? '17:00').toString(),
      pickupTo: (data['pickupTo'] ?? '19:00').toString(),
      photo: (data['photo'] ?? '').toString(),
      createdAt: (data['createdAt'] as num? ?? 0).toInt(),
    );
  }
}

class CampusOrder {
  final String id;
  final String offerId;
  final String shopId;
  final String studentId;
  final String studentName;
  final String title;
  final int quantity;
  final double total;
  final double originalTotal;
  final String status; // 'reserved' | 'paid' | 'collected' | 'cancelled' | 'expired'
  final int createdAt;
  final int expiresAt;
  final int? releasedAt;
  final String? paymentRef;
  final String? qrToken;

  CampusOrder({
    required this.id,
    required this.offerId,
    required this.shopId,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.quantity,
    required this.total,
    required this.originalTotal,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.releasedAt,
    this.paymentRef,
    this.qrToken,
  });

  factory CampusOrder.fromMap(String id, Map<String, dynamic> data) {
    return CampusOrder(
      id: id,
      offerId: (data['offerId'] ?? '').toString(),
      shopId: (data['shopId'] ?? '').toString(),
      studentId: (data['studentId'] ?? '').toString(),
      studentName: (data['studentName'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      quantity: (data['quantity'] as num? ?? 1).toInt(),
      total: (data['total'] as num? ?? 0).toDouble(),
      originalTotal: (data['originalTotal'] as num? ?? 0).toDouble(),
      status: (data['status'] ?? 'reserved').toString(),
      createdAt: (data['createdAt'] as num? ?? 0).toInt(),
      expiresAt: (data['expiresAt'] as num? ?? 0).toInt(),
      releasedAt: (data['releasedAt'] as num?)?.toInt(),
      paymentRef: data['paymentRef'] as String?,
      qrToken: data['qrToken'] as String?,
    );
  }
}
