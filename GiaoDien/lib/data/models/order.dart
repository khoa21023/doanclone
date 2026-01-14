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
      productId: json['SanPhamId']?.toString() ?? '',
      productName: json['TenSanPham'] ?? 'Sản phẩm',
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
    if (json['items'] != null) {
      listItems = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    DateTime parseDate(dynamic dateString) {
      if (dateString == null) return DateTime.now();
      try {
        return DateTime.parse(dateString.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Order(
      id: json['Id']?.toString() ?? 'Unknown',
      userName: json['HoTen'] ?? 'Khách lẻ',
      userEmail: json['Email'] ?? 'Không có email',
      userPhone: json['SoDienThoai'] ?? '',
      total: double.tryParse(json['TongTienHang']?.toString() ?? '0') ?? 0.0,
      status: _mapStatusToEnglish(json['TrangThaiDonHang']),
      createdAt: parseDate(json['NgayDat']),
      paymentMethod: json['TrangThaiThanhToan'] ?? '0',
      address: json['DiaChiGiao'] ?? '',
      items: listItems,
    );
  }

  static String _mapStatusToEnglish(String? vnStatus) {
    final s = vnStatus?.toLowerCase() ?? '';
    if (s == 'đã đặt') return 'placed';
    if (s == 'đang giao') return 'processing';
    if (s == 'đã giao') return 'completed';
    if (s == 'đã hủy') return 'cancelled';
    return 'placed';
  }

  String get statusInVietnamese {
    switch (status) {
      case 'placed':
        return 'Đã Đặt';
      case 'processing':
        return 'Đang Giao';
      case 'completed':
        return 'Đã Giao';
      case 'cancelled':
        return 'Đã Hủy';
      default:
        return 'Mới';
    }
  }
}
