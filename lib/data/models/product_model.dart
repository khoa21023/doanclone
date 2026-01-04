class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String color;
  final String storage;
  final String type;
  final String condition;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.color,
    this.storage = '',
    required this.type,
    required this.condition,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product, 
    this.quantity = 1,
  });
}