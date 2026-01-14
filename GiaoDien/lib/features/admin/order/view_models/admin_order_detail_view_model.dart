import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/order.dart';

class AdminOrderDetailViewModel extends ChangeNotifier {
  final Order _order;
  late String _currentStatus;
  bool _isLoading = false;
  String? _errorMessage;

  AdminOrderDetailViewModel(this._order) {
    _currentStatus = _order.status;
  }

  // Getters
  Order get order => _order;
  String get currentStatus => _currentStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Logic xác định bước hiển thị trên thanh Progress Bar
  int get currentStep {
    if (_currentStatus == 'processing') return 2;
    if (_currentStatus == 'completed') return 3;
    if (_currentStatus == 'cancelled') return 0; // 0 là lỗi/hủy
    return 1; // Default: placed (Mới đặt)
  }

  // HÀM GỌI API CẬP NHẬT TRẠNG THÁI
  Future<bool> updateStatus(String newStatusEnglish) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // 1. Chuyển đổi trạng thái từ Anh (App) sang Việt (DB)
      String dbStatus = _mapEnglishToVietnamese(newStatusEnglish);

      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/orders/admin/status/${_order.id}',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': dbStatus, // Gửi tiếng Việt lên Server
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Cập nhật thành công
        _currentStatus = newStatusEnglish;
        _order.status =
            newStatusEnglish; // Cập nhật luôn vào object gốc để khi back về dashboard nó tự update
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Cập nhật thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helper map ngược lại để gửi lên Server
  String _mapEnglishToVietnamese(String englishStatus) {
    switch (englishStatus) {
      case 'placed':
        return 'Đã Đặt';
      case 'processing':
        return 'Đang Giao';
      case 'completed':
        return 'Đã Giao'; // Hoặc 'Thành Công' tùy dữ liệu mẫu của bạn
      case 'cancelled':
        return 'Đã Hủy';
      default:
        return 'Đã Đặt';
    }
  }
}
