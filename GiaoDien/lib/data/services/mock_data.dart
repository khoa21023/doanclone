// import '/data/models/order.dart';
// import '/data/models/promotion.dart';
// import '../models/product_model.dart'; // Đảm bảo import model Product

// class MockData {
//   // --- Dữ liệu User ---
//   static List<Map<String, String>> users = [
//     {'email': 'admin@gmail.com', 'password': 'admin123', 'name': 'Admin User'},
//   ];

//   static bool register(String email, String password, String name) {
//     bool exists = users.any((user) => user['email'] == email);
//     if (exists) return false;
//     users.add({'email': email, 'password': password, 'name': name});
//     return true;
//   }

//   static bool login(String email, String password) {
//     return users.any(
//       (user) => user['email'] == email && user['password'] == password,
//     );
//   }

//   // --- Dữ liệu Khuyến mãi ---
//   static List<Promotion> promotions = [
//     Promotion(
//       id: "PROMO-001",
//       type: "voucher",
//       code: "SAVE20",
//       discountPercent: 20,
//       isActive: true,
//       expiresAt: DateTime.now().add(const Duration(days: 30)),
//     ),
//   ];

//   static void addPromotion(Promotion p) => promotions.add(p);

//   static void deletePromotion(String id) =>
//       promotions.removeWhere((p) => p.id == id);

//   static void togglePromotion(String id) {
//     final p = promotions.firstWhere((element) => element.id == id);
//     p.isActive = !p.isActive;
//   }
// }
