import '/data/models/order.dart';
import '/data/models/promotion.dart';
import '../models/product_model.dart'; // Đảm bảo import model Product

class MockData {
  // --- Dữ liệu User ---
  static List<Map<String, String>> users = [
    {'email': 'admin@gmail.com', 'password': 'admin123', 'name': 'Admin User'},
  ];

  static bool register(String email, String password, String name) {
    bool exists = users.any((user) => user['email'] == email);
    if (exists) return false;
    users.add({'email': email, 'password': password, 'name': name});
    return true;
  }

  static bool login(String email, String password) {
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

  // --- BỔ SUNG: DỮ LIỆU SẢN PHẨM (Phần bạn đang thiếu) ---
  static List<Product> products = [
    // 1. ỐP LƯNG (Quan trọng: type='Ốp lưng', brand phải có để lọc sub-category)
    Product(
      id: 'case1',
      name: 'Ốp lưng Chống sốc S23 Ultra',
      price: 129000,
      imageUrl:
          'https://cuahangsamsung.vn/filemanager/userfiles/2023/12/4-2.png',
      color: 'Đen',
      type: 'Ốp lưng', // Khớp với tên danh mục
      condition: 'Mới',
      brand: 'Samsung', // Dùng để lọc sub-category
      rating: 4.5,
      reviews: 12,
    ),
    Product(
      id: 'case2',
      name: 'Ốp lưng Da iPhone 15 Pro',
      price: 159000,
      imageUrl:
          'https://lesang.vn/images/san-pham/bao-da-iphone-15-pro-max-qlino-wallet-da-bo-that.jpg',
      color: 'Nâu',
      type: 'Ốp lưng',
      condition: 'Mới',
      brand: 'iPhone',
      rating: 4.8,
      reviews: 30,
    ),
    Product(
      id: 'case3',
      name: 'Ốp lưng Xiaomi 13 Pro',
      price: 89000,
      imageUrl:
          'https://product.hstatic.net/1000341816/product/1_aa9b228400c7471c96686b0be9f8c855_grande.jpg',
      color: 'Trong suốt',
      type: 'Ốp lưng',
      condition: 'Mới',
      brand: 'Xiaomi',
      rating: 4.2,
      reviews: 8,
    ),

    // 2. MÀN HÌNH
    Product(
      id: 'screen1',
      name: 'Màn hình iPhone 14 Pro Max (Zin bóc máy)',
      price: 8500000,
      imageUrl:
          'https://linhkiennamviet.vn/wp-content/uploads/2024/06/Man-hinh-iPhone-14-Pro-Max_linhkiennamviet.vn_.jpg',
      color: 'Đen',
      type: 'Màn hình',
      condition: '99%',
      brand: 'iPhone',
      rating: 5.0,
      reviews: 5,
    ),

    // 3. PIN
    Product(
      id: 'bat1',
      name: 'Pin Pisen dung lượng cao iPhone 11',
      price: 450000,
      imageUrl:
          'https://cdni.dienthoaivui.com.vn/x,webp,q100/https://dashboard.dienthoaivui.com.vn/uploads/wp-content/uploads/images/thay-pin-iphone-11-dung-luong-sieu-cao-pisen-7.jpg',
      color: 'Đen',
      type: 'Pin',
      condition: 'Mới',
      brand: 'Pisen',
      rating: 4.7,
      reviews: 150,
    ),

    // 4. CAMERA
    Product(
      id: 'cam1',
      name: 'Cụm Camera sau Samsung S22 Ultra',
      price: 2100000,
      imageUrl:
          'https://chiemtaimobile.vn/images/detailed/41/cum-camera-sau-galaxy-s22-ultra-s22-ultra-5g-s908-zin-may.jpg', // Ảnh minh họa
      color: 'Đen',
      type: 'Camera',
      condition: 'Zin',
      brand: 'Samsung',
      rating: 4.9,
      reviews: 3,
    ),

    // 5. MOTOR
    Product(
      id: 'motor1',
      name: 'Motor rung Taptic Engine iPhone 12',
      price: 150000,
      imageUrl:
          'https://thuanphatmobile.vn/images/cuc-rung-iphone-12-pro-max.jpg',
      color: 'Bạc',
      type: 'Motor',
      condition: 'Zin',
      brand: 'iPhone',
      rating: 4.5,
      reviews: 10,
    ),

    // 6. PHỤ KIỆN
    Product(
      id: 'acc1',
      name: 'Củ sạc nhanh 20W Apple',
      price: 490000,
      imageUrl:
          'https://cdn.tgdd.vn/Products/Images/9499/230315/adapter-sac-type-c-20w-cho-iphone-ipad-apple-mhje3-avatar-1-1-600x600.jpg',
      color: 'Trắng',
      type: 'Phụ kiện',
      condition: 'Mới',
      brand: 'Apple',
      rating: 4.9,
      reviews: 500,
    ),
  ];
}
