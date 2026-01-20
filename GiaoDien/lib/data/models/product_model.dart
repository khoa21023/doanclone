class Product {
  final String id;
  final String name;
  final double sellPrice;
  final double originalPrice;
  final String imageUrl;
  final String color;
  final String storage;
  final String categoryId;
  final String brand;
  final String description;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.sellPrice,
    required this.originalPrice,
    required this.imageUrl,
    this.color = '',
    this.storage = '',
    this.categoryId = '',
    this.brand = '',
    this.description = '',
    this.stock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // --- LOGIC XỬ LÝ ẢNH THÔNG MINH ---
    String rawImage = json['HinhAnh'] ?? '';
    String finalUrl;

    if (rawImage.startsWith('http')) {
      // TRƯỜNG HỢP 1: Đã là link Cloudinary hoặc link online -> Dùng luôn
      finalUrl = rawImage;
    } else if (rawImage.isNotEmpty) {
      // TRƯỜNG HỢP 2: Là tên file cũ (vd: ap2.jpg)
      // Vì server Render không còn giữ file ảnh local, ta dùng ảnh mẫu tạm thời
      // để App hiển thị đẹp mắt thay vì lỗi gạch chéo.
      // Bạn có thể update DB sau để thay thế ảnh này.
      finalUrl =
          'https://via.placeholder.com/300?text=${Uri.encodeComponent(json['TenSanPham'] ?? 'Product')}';
    } else {
      // TRƯỜNG HỢP 3: Không có dữ liệu ảnh
      finalUrl = 'https://via.placeholder.com/300?text=No+Image';
    }
    // ------------------------------------

    return Product(
      id: json['Id'].toString(),
      name: json['TenSanPham'] ?? 'Sản phẩm',
      sellPrice: double.tryParse(json['GiaBan'].toString()) ?? 0.0,
      originalPrice: double.tryParse(json['GiaGoc'].toString()) ?? 0.0,
      imageUrl: finalUrl,
      color: json['MauSac'] ?? '',
      storage: json['DungLuong'] ?? '',
      categoryId: json['DanhMucId']?.toString() ?? '',
      brand: json['HangSanXuat'] ?? 'Other',
      description: json['MoTa'] ?? '',
      stock: int.tryParse(json['SoLuongTon'].toString()) ?? 0,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json),
      quantity: json['SoLuong'] ?? 1,
    );
  }
}
