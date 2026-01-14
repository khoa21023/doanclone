class Promotion {
  final String id;
  final String code; // SQL: MaCode
  final double discountAmount; // SQL: SoTienGiam (Giảm theo số tiền cụ thể)
  final double minOrderValue; // SQL: DonToiThieu
  final int quantity; // SQL: SoLuong
  final DateTime startDate; // SQL: NgayBatDau
  final DateTime endDate; // SQL: NgayKetThuc

  Promotion({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.minOrderValue,
    required this.quantity,
    required this.startDate,
    required this.endDate,
  });

  // Map từ JSON Server trả về (Khớp 100% với file promotionModel.js)
  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['Id']?.toString() ?? '',
      code: json['MaCode'] ?? '',

      // Xử lý số an toàn
      discountAmount:
          double.tryParse(json['SoTienGiam']?.toString() ?? '0') ?? 0.0,
      minOrderValue:
          double.tryParse(json['DonToiThieu']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['SoLuong']?.toString() ?? '0') ?? 0,

      // Xử lý ngày tháng
      startDate: json['NgayBatDau'] != null
          ? DateTime.parse(json['NgayBatDau'].toString())
          : DateTime.now(),
      endDate: json['NgayKetThuc'] != null
          ? DateTime.parse(json['NgayKetThuc'].toString())
          : DateTime.now(),
    );
  }

  // Kiểm tra xem mã còn hạn không
  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && quantity > 0;
  }
}
