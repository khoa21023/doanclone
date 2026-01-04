import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  double get totalAmount {
    var total = 0.0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  // Cập nhật hàm addItem để nhận cả thông tin Custom
  void addItem(Product product, {int quantity = 1, bool isCustom = false, Uint8List? img, String? text, String? sticker}) {
    // Nếu là hàng thiết kế riêng -> Luôn thêm mới, không cộng dồn số lượng
    if (isCustom) {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        isCustomDesign: true,
        customImage: img,
        customText: text,
        sticker: sticker,
      ));
    } else {
      // Hàng thường -> Cộng dồn nếu trùng ID
      final index = _items.indexWhere((item) => item.product.id == product.id && !item.isCustomDesign);
      if (index >= 0) {
        _items[index].quantity += quantity;
      } else {
        _items.add(CartItem(product: product, quantity: quantity));
      }
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