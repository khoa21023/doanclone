import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../cart/view_models/cart_view_model.dart';

class CheckoutViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _checkoutUrl; // Lưu link thanh toán nếu có (Visa/QR)

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get checkoutUrl => _checkoutUrl;

  String? _lastOrderId;
  String? get lastOrderId => _lastOrderId;

  static const String _baseUrl = 'https://mobile-tech-ct.onrender.com/api';

  Future<bool> placeOrder({
    required String name,
    required String phone,
    required String address,
    required String note,
    required String paymentMethod,
    required CartViewModel cartViewModel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _checkoutUrl = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('$_baseUrl/orders/my-orders/create_pay');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'TenNguoiNhan': name,
          'SdtNguoiNhan': phone,
          'DiaChiGiao': address,
          'GhiChu': note,
          'PhuongThucThanhToan': paymentMethod,
        }),
      );

      final data = jsonDecode(response.body);

      // Backend trả về status 200 và error: false là thành công
      if (response.statusCode == 200 && data['error'] == false) {
        // 1. Refresh giỏ hàng
        await cartViewModel.fetchCart();

        // 2. Kiểm tra link thanh toán (nếu là Visa/PayOS)
        if (paymentMethod == 'visa' && data['checkoutUrl'] != null) {
          _checkoutUrl = data['checkoutUrl'];
          // Logic mở link: Bạn có thể xử lý mở WebView hoặc launchUrl ở View dựa trên biến này
        }

        return true;
      } else {
        // Lấy thông báo lỗi từ server trả về
        _errorMessage =
            data['message'] ?? "Đặt hàng thất bại. Vui lòng thử lại.";
        return false;
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối hoặc hệ thống. Vui lòng kiểm tra mạng.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
