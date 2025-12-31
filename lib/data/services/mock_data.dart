import '/data/models/order.dart';
import '/data/models/promotion.dart';

class MockData {
  // Đây là danh sách chứa các user đã đăng ký
  // Lưu sẵn 1 tài khoản Admin để test
  static List<Map<String, String>> users = [
    {
      'email': 'admin@phoneparts.com',
      'password': 'admin123',
      'name': 'Admin User',
    },
  ];

  // Hàm thêm user mới (Đăng ký)
  static bool register(String email, String password, String name) {
    // Kiểm tra xem email đã tồn tại chưa
    bool exists = users.any((user) => user['email'] == email);
    if (exists) return false; // Đăng ký thất bại

    users.add({'email': email, 'password': password, 'name': name});
    return true; // Thành công
  }

  // Hàm kiểm tra đăng nhập
  static bool login(String email, String password) {
    // Tìm xem có user nào khớp cả email và password không
    return users.any(
      (user) => user['email'] == email && user['password'] == password,
    );
  }

  // --- Dữ liệu Đơn hàng ---
  static List<Order> orders = [
    Order(
      id: "ORD-001",
      userName: "Nguyễn Văn A",
      userEmail: "nguyenvana@example.com",
      items: [
        OrderItem(
          productId: "1",
          productName: "Màn hình OLED iPhone 14 Pro",
          quantity: 1,
          price: 299.99,
        ),
      ],
      total: 299.99,
      status: "placed",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: "Credit Card",
    ),
    Order(
      id: "ORD-002",
      userName: "Trần Thị B",
      userEmail: "tranthib@example.com",
      items: [
        OrderItem(
          productId: "2",
          productName: "Pin Samsung Galaxy S23",
          quantity: 2,
          price: 49.99,
        ),
      ],
      total: 99.98,
      status: "processing",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: "PayPal",
    ),
  ];

  static void updateOrderStatus(String orderId, String newStatus) {
    final order = orders.firstWhere((o) => o.id == orderId);
    order.status = newStatus;
  }

  // --- Dữ liệu Khuyến mãi ---
  static List<Promotion> promotions = [
    Promotion(
      id: "PROMO-001",
      type: "voucher",
      code: "SAVE20",
      discountPercent: 20,
      isActive: true,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  static void addPromotion(Promotion p) => promotions.add(p);

  static void deletePromotion(String id) =>
      promotions.removeWhere((p) => p.id == id);

  static void togglePromotion(String id) {
    final p = promotions.firstWhere((element) => element.id == id);
    p.isActive = !p.isActive;
  }
}
