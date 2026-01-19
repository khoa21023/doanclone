// Model dành riêng cho Admin (Logic cũ)
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['SanPhamId'] ?? json['productId'] ?? '').toString(),
      productName: json['TenSanPham'] ?? json['productName'] ?? 'Sản phẩm',
      quantity: int.tryParse(json['SoLuong']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['GiaLucMua']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class Order {
  final String id;
  final String userName;
  final String userEmail;
  final String userPhone;
  final List<OrderItem> items;
  final double total;

  // Admin cần sửa trạng thái này (không để final)
  String status;

  final DateTime createdAt;
  final String paymentMethod;
  final String address;

  Order({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
    required this.address,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> listItems = [];
    if (json['products'] != null) {
      listItems = (json['products'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: (json['Id'] ?? json['id'] ?? 'Unknown').toString(),
      userName: json['HoTen'] ?? 'Khách',
      userEmail: json['Email'] ?? '',
      userPhone: json['SoDienThoai'] ?? '',
      total:
          double.tryParse(
            json['ThanhTien']?.toString() ?? json['total']?.toString() ?? '0',
          ) ??
          0.0,

      // Logic map sang tiếng Anh cho Admin
      status: _mapStatusToEnglish(json['TrangThaiDonHang'] ?? json['status']),

      createdAt: json['NgayDat'] != null
          ? DateTime.parse(json['NgayDat'])
          : DateTime.now(),
      paymentMethod: json['TrangThaiThanhToan'] ?? 'COD',
      address: json['DiaChiGiao'] ?? '',
      items: listItems,
    );
  }

  static String _mapStatusToEnglish(String? vnStatus) {
    final s = vnStatus?.toLowerCase() ?? '';
    if (s == 'đã đặt' || s == 'chờ xác nhận' || s == 'choxacnhan')
      return 'placed';
    if (s == 'đang giao' || s == 'danggiao') return 'processing';
    if (s == 'đã giao' || s == 'dagiao') return 'completed';
    if (s == 'đã hủy' || s == 'dahuy' || s == 'đã huỷ') return 'cancelled';
    return 'placed';
  }

  // Getter cho Admin UI
  String get statusInVietnamese {
    switch (status) {
      case 'placed':
        return 'Chờ xác nhận';
      case 'processing':
        return 'Đang giao';
      case 'completed':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Chờ xác nhận';
    }
  }
}
