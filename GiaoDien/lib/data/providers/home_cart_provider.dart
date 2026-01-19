import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  double get totalAmount {
    var total = 0.0;
    for (var item in _items) {
      total += item.product.sellPrice * item.quantity;
    }
    return total;
  }

  void addItem(Product product, {int quantity = 1}) {
    // Kiểm tra xem sản phẩm đã có trong giỏ
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // Nếu có  -> Tăng số lượng
      _items[index].quantity += quantity;
    } else {
      // Nếu chưa có -> Thêm mới
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void decreaseItem(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
