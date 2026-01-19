import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/client_order.dart';

class OrderViewModel extends ChangeNotifier {
  List<ClientOrder> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ClientOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ClientOrder? _currentOrderDetail;
  ClientOrder? get currentOrderDetail => _currentOrderDetail;

  Future<void> fetchOrderDetails(String orderId) async {
    _isLoading = true;
    _currentOrderDetail = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Sử dụng đúng route: /api/orders/detail/:id
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/orders/detail/$orderId',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _currentOrderDetail = ClientOrder.fromJson(data['data']);
      } else {
        _errorMessage = data['message'] ?? "Không thể lấy chi tiết đơn hàng";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/orders/my-orders',
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
          final List<dynamic> listData = data['data'];
          // Map sang ClientOrder
          _orders = listData.map((e) => ClientOrder.fromJson(e)).toList();
        } else {
          _orders = [];
        }
      } else {
        _errorMessage = "Lỗi tải đơn hàng: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
