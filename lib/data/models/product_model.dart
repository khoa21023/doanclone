import 'dart:typed_data'; // Import này cần cho customImage

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String color;
  final String storage;
  final String type; // 'phone', 'accessory', 'case'
  final String condition;
  
  // Thêm các trường hỗ trợ UI của bạn
  final String brand; // Apple, Samsung... (Để lọc)
  final double rating;
  final int reviews;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.color,
    this.storage = '',
    required this.type,
    required this.condition,
    // Giá trị mặc định để không lỗi code cũ của nhóm
    this.brand = 'Other', 
    this.rating = 0.0,
    this.reviews = 0,
  });
}

class CartItem {
  final Product product;
  int quantity;
  
  // --- THÊM CÁC TRƯỜNG CHO TÍNH NĂNG TỰ THIẾT KẾ ---
  final bool isCustomDesign;
  final Uint8List? customImage; // Ảnh thiết kế
  final String? customText;     // Chữ in lên ốp
  final String? sticker;        // Sticker

  CartItem({
    required this.product, 
    this.quantity = 1,
    this.isCustomDesign = false,
    this.customImage,
    this.customText,
    this.sticker,
  });
}