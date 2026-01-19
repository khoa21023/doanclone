import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/product_model.dart';

class ClientProductViewModel extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;

  // --- GETTERS ---
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- HÀM GỌI API ---
  Future<void> fetchProducts({
    String? category,
    String? keyword,
    String? sortOption,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      String queryString = "?";

      if (category != null && category != "Tất cả") {
        String categoryId = _getCategoryIdByName(category);
        queryString += "category=$categoryId&";
      }

      if (keyword != null && keyword.isNotEmpty) {
        queryString += "name=${Uri.encodeComponent(keyword)}&";
      }

      // Sắp xếp
      if (sortOption != null) {
        String sortParam = 'new';
        if (sortOption == 'Giá: Thấp đến Cao') sortParam = 'priceAsc';
        if (sortOption == 'Giá: Cao đến Thấp') sortParam = 'priceDesc';
        if (sortOption == 'Hot') sortParam = 'hot';
        queryString += "sort=$sortParam";
      }

      // Gọi API
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/products$queryString',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Xử lý kết quả
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> listData = data['data'];
          _products = listData.map((e) => Product.fromJson(e)).toList();
        } else {
          _products = [];
        }
      } else {
        _errorMessage = "Lỗi tải dữ liệu: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
    } finally {
      _isLoading = false;
      notifyListeners(); // Báo cho View tắt loading và vẽ lại
    }
  }

  // --- HÀM TÌM KIẾM THÔNG MINH ---
  // Giúp không gọi API liên tục khi người dùng đang gõ
  void onSearchChanged(
    String query,
    String currentCategory,
    String currentSort,
  ) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchProducts(
        keyword: query,
        category: currentCategory,
        sortOption: currentSort,
      );
    });
  }

  String _getCategoryIdByName(String name) {
    switch (name) {
      case "Màn hình":
        return "1";
      case "Pin":
        return "2";
      case "Camera":
        return "3";
      case "Cổng sạc":
        return "DM02";
      case "Loa":
        return "DM01";
      case "Ốp lưng":
        return "DM03";
      case "Motor":
        return "7";
      case "Nút":
        return "DM04";
      case "Phụ kiện":
        return "9";
      default:
        return "";
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
