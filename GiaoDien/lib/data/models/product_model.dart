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
    return Product(
      id: json['Id'].toString(),
      name: json['TenSanPham'] ?? 'Sản phẩm',
      sellPrice: double.tryParse(json['GiaBan'].toString()) ?? 0.0,
      originalPrice: double.tryParse(json['GiaGoc'].toString()) ?? 0.0,
      imageUrl: json['HinhAnh'] != null
          ? 'https://mobile-tech-ct.onrender.com/uploads/${json['HinhAnh']}'
          : 'https://via.placeholder.com/150',

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
