import 'order.dart'; // Import to use OrderItem class

class ClientOrder {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;
  final String paymentStatus;
  final String address; // Added to fix image_601905
  final String paymentMethod; // Added to fix image_601905
  final List<OrderItem> items; // Added to fix image_607285

  ClientOrder({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.paymentStatus,
    required this.address,
    required this.paymentMethod,
    required this.items,
  });

  factory ClientOrder.fromJson(Map<String, dynamic> json) {
    // Parse items if they exist in the JSON response
    var list = json['products'] as List?;
    List<OrderItem> itemList = list != null
        ? list.map((i) => OrderItem.fromJson(i)).toList()
        : [];

    return ClientOrder(
      id: json['Id']?.toString() ?? '',
      status: json['TrangThaiDonHang'] ?? 'ChoXacNhan',
      total: double.tryParse(json['ThanhTien']?.toString() ?? '0') ?? 0.0,
      createdAt: json['NgayDat'] != null
          ? DateTime.parse(json['NgayDat'])
          : DateTime.now(),
      paymentStatus: json['TrangThaiThanhToan'] ?? 'Chưa thanh toán',
      address: json['DiaChiGiao'] ?? '', // Map from DB column
      paymentMethod: json['PhuongThucThanhToan'] ?? 'COD',
      items: itemList,
    );
  }

  // Your existing displayStatus getter
  String get displayStatus {
    if (status == 'ChoXacNhan' || status == 'Đã Đặt') return 'Chờ xác nhận';
    if (status == 'DangGiao' || status == 'Đang Giao') return 'Đang giao';
    if (status == 'DaGiao' || status == 'Đã Giao') return 'Đã giao';
    if (status == 'DaHuy' || status == 'Đã Hủy' || status == 'Đã Huỷ')
      return 'Đã hủy';
    return status;
  }
}
