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
}

class Order {
  final String id;
  final String userName;
  final String userEmail;
  final List<OrderItem> items;
  final double total;
  String status; // 'placed', 'processing', 'completed'
  final DateTime createdAt;
  final String paymentMethod;

  Order({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
  });
}
