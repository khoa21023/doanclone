class Promotion {
  final String id;
  final String type; // 'voucher', 'product'
  final String? code;
  final String? productId;
  final int discountPercent;
  bool isActive;
  final DateTime expiresAt;

  Promotion({
    required this.id,
    required this.type,
    this.code,
    this.productId,
    required this.discountPercent,
    required this.isActive,
    required this.expiresAt,
  });
}
