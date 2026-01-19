import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/cart_model.dart';

class CartViewModel extends ChangeNotifier {
  List<CartItem> _items = [];
  CartSummary _summary = CartSummary(subTotal: 0, shippingFee: 0, total: 0);
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get items => _items;
  CartSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy số lượng item để hiện Badge trên icon giỏ hàng
  int get itemCount => _items.length;

  // 1. LẤY GIỎ HÀNG
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('https://mobile-tech-ct.onrender.com/api/cart');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Parse danh sách items
          final List<dynamic> listItems = data['data']['items'];
          _items = listItems.map((e) => CartItem.fromJson(e)).toList();

          // Parse thông tin tổng tiền
          _summary = CartSummary.fromJson(data['data']['summary']);
        }
      } else {
        _errorMessage = "Không tải được giỏ hàng";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. THÊM VÀO GIỎ (Gọi từ Home hoặc Detail)
  Future<bool> addToCart(String productId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('https://mobile-tech-ct.onrender.com/api/cart/add');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Thêm thành công thì tải lại giỏ hàng để cập nhật số lượng badge
        fetchCart();
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi thêm giỏ hàng: $e");
      return false;
    }
  }

  // 3. CẬP NHẬT SỐ LƯỢNG (Tăng/Giảm)
  Future<void> updateQuantity(String cartId, int newQuantity) async {
    // Optimistic Update: Cập nhật UI trước cho mượt
    final index = _items.indexWhere((item) => item.cartId == cartId);
    if (index != -1) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/cart/update-quantity',
      );

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'cartId': cartId, 'quantity': newQuantity}),
      );

      // Gọi lại fetchCart để tính toán lại tổng tiền chuẩn từ server
      await fetchCart();
    } catch (e) {
      print("Lỗi update quantity: $e");
      fetchCart(); // Revert lại nếu lỗi
    }
  }

  // 4. XÓA SẢN PHẨM
  Future<void> removeItem(String cartId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/cart/remove/$cartId',
      );

      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Xóa item khỏi list local ngay lập tức
        _items.removeWhere((item) => item.cartId == cartId);
        notifyListeners();
        // Tải lại để cập nhật tổng tiền
        fetchCart();
      }
    } catch (e) {
      print("Lỗi xóa item: $e");
    }
  }
}
