import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/product_model.dart';

class WishlistViewModel extends ChangeNotifier {
  List<Product> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. LẤY DANH SÁCH YÊU THÍCH
  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      // Giả định route backend là /api/favorites
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/favorites',
      );

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
          // Backend trả về mảng sản phẩm phẳng (sp.* joined), nên map trực tiếp được
          final List<dynamic> listData = data['data'];
          _items = listData.map((e) => Product.fromJson(e)).toList();
        } else {
          _items = [];
        }
      }
    } catch (e) {
      _errorMessage = "Lỗi tải wishlist: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. KIỂM TRA ĐÃ THÍCH CHƯA
  bool isFavorite(String productId) {
    return _items.any((item) => item.id == productId);
  }

  // 3. TOGGLE (THÊM/XÓA) - Dùng cho nút Tim
  Future<void> toggleFavorite(Product product) async {
    final isExist = isFavorite(product.id);

    // Optimistic Update (Cập nhật UI trước cho mượt)
    if (isExist) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();

    // Gọi API ngầm
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = 'https://mobile-tech-ct.onrender.com/api/favorites';

      http.Response response;

      if (isExist) {
        final url = Uri.parse('$baseUrl/remove/${product.id}');
        response = await http.delete(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode >= 500) {
          _items.add(product);
          notifyListeners();
        }
      } else {
        // Gọi API Thêm
        final url = Uri.parse('$baseUrl/add');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'productId': product.id}),
        );
      }

      // Nếu lỗi API thì hoàn tác lại UI
      if (response.statusCode != 200 && response.statusCode != 201) {
        if (isExist) {
          _items.add(product); // Thêm lại nếu xóa lỗi
        } else {
          _items.removeWhere(
            (item) => item.id == product.id,
          ); // Xóa đi nếu thêm lỗi
        }
        notifyListeners();
        print("Lỗi Toggle Favorite: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối Wishlist: $e");
      // Hoàn tác nếu lỗi mạng
      if (isExist)
        _items.add(product);
      else
        _items.removeWhere((item) => item.id == product.id);
      notifyListeners();
    }
  }
}
