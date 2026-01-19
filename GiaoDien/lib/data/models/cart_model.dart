class CartItem {
  final String cartId;
  final String productId;
  final String name;
  final double price;
  final String image;
  int quantity;
  final double totalItemPrice;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.totalItemPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['Id'] ?? '',
      productId: json['SanPhamId'] ?? '',
      name: json['TenSanPham'] ?? '',
      price: double.tryParse(json['GiaBan'].toString()) ?? 0,
      image: json['HinhAnh'] ?? '',
      quantity: json['SoLuong'] ?? 1,
      totalItemPrice: double.tryParse(json['ThanhTienMon'].toString()) ?? 0,
    );
  }
}

class CartSummary {
  final double subTotal;
  final double shippingFee;
  final double total;

  CartSummary({
    required this.subTotal,
    required this.shippingFee,
    required this.total,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      subTotal: double.tryParse(json['tamTinh'].toString()) ?? 0,
      shippingFee: double.tryParse(json['phiShip'].toString()) ?? 0,
      total: double.tryParse(json['thanhTien'].toString()) ?? 0,
    );
  }
}
