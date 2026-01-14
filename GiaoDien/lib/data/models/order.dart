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
      productName: json['TenSanPham'] ?? '',
      quantity: json['SoLuong'] ?? 0,
      price: double.tryParse(json['GiaLucMua'].toString()) ?? 0.0,
    );
  }
}

class Order {
  final String id;
  final String userName;
  final String userEmail;
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

    return Order(
      id: json['Id'].toString(),
      userName: json['HoTen'] ?? 'Khách lẻ',
      userEmail: json['Email'] ?? '',
      items: listItems,
      total: double.tryParse(json['TongTien'].toString()) ?? 0.0,

      status: _mapStatusToEnglish(json['TrangThaiDonHang']),

      createdAt: json['NgayDat'] != null
          ? DateTime.parse(json['NgayDat'])
          : DateTime.now(),

      paymentMethod: json['PhuongThucThanhToan'] ?? 'COD',
      address: json['DiaChiGiaoHang'] ?? '',
    );
  }

  static String _mapStatusToEnglish(String? vnStatus) {
    switch (vnStatus) {
      case 'Đã Đặt':
        return 'placed';
      case 'Đang Giao':
        return 'processing';
      case 'Đã Giao':
        return 'completed';
      case 'Đã Hủy':
        return 'cancelled';
      default:
        return 'placed';
    }
  }

  String get statusInVietnamese {
    switch (status) {
      case 'placed':
        return 'Chờ xác nhận';
      case 'processing':
        return 'Đang giao hàng';
      case 'completed':
        return 'Giao thành công';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không rõ';
    }
  }
}
