import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String color;
  final String storage;
  final String type; // 'phone', 'accessory', 'case'
  final String condition;

  final String brand; // Apple, Samsung... (Để lọc)
  final double rating;
  final int reviews;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.color,
    this.storage = '',
    required this.type,
    required this.condition,
    this.brand = 'Other', 
    this.rating = 0.0,
    this.reviews = 0,
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