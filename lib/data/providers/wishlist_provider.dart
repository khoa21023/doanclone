import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  bool isFavorite(String productId) {
    return _items.any((item) => item.id == productId);
  }

  void toggleFavorite(Product product) {
    final existingIndex = _items.indexWhere((item) => item.id == product.id);
    if (existingIndex >= 0) {
      _items.removeAt(existingIndex);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }
}