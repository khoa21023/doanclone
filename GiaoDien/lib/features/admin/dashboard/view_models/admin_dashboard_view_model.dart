import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Đảm bảo import đúng đường dẫn file model Order mới
import '../../../../data/models/order.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Gọi API lấy danh sách đơn hàng
  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _errorMessage = "Phiên đăng nhập hết hạn.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // API Admin lấy tất cả đơn
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/orders/admin/all',
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
        // API trả về: { success: true, data: [...] }
        if (data['data'] != null) {
          final List<dynamic> listData = data['data'];
          _orders = listData.map((json) => Order.fromJson(json)).toList();
        } else {
          _orders = [];
        }

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = "Lỗi tải dữ liệu: ${response.statusCode}";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Thống kê ---
  double get totalRevenue {
    // Chỉ tính tiền các đơn chưa hủy
    return _orders
        .where((o) => o.status != 'cancelled')
        .fold(0.0, (sum, order) => sum + order.total);
  }

  int get totalOrders => _orders.length;
  int get placedCount => _orders.where((o) => o.status == 'placed').length;
  int get processingCount =>
      _orders.where((o) => o.status == 'processing').length;
  int get completedCount =>
      _orders.where((o) => o.status == 'completed').length;
}
