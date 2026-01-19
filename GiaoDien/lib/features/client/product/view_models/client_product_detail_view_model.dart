import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/product_model.dart';

class ClientProductDetailViewModel extends ChangeNotifier {
  Product? _product; // Dữ liệu chi tiết mới nhất từ Server
  bool _isLoading = false;
  String? _errorMessage;

  Product? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Gọi API lấy chi tiết (Đồng thời Backend sẽ +1 lượt xem)
  Future<void> fetchProductDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // API: /api/products/:id
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/products/$id',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _product = Product.fromJson(data['data']);
        } else {
          _errorMessage = data['message'];
        }
      } else {
        _errorMessage = "Lỗi tải dữ liệu: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
