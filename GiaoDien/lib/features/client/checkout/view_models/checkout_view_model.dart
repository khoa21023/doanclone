import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../cart/view_models/cart_view_model.dart';
import '../../../../data/models/user_profile.dart';

class CheckoutViewModel extends ChangeNotifier {
  bool _isLoading = false;
  UserProfile? _userProfile;
  String? _errorMessage;
  String? _checkoutUrl;

  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  String? get checkoutUrl => _checkoutUrl;

  String? _lastOrderId;
  String? get lastOrderId => _lastOrderId;

  static const String _baseUrl = 'https://mobile-tech-ct.onrender.com/api';

  // --- LOGIC NGHIỆP VỤ (Đoán thành phố) ---
  String detectCityFromAddress(String address) {
    final lowerAddr = address.toLowerCase();
    if (lowerAddr.contains("hcm") || lowerAddr.contains("hồ chí minh")) {
      return "TP.HCM";
    }
    if (lowerAddr.contains("hà nội")) {
      return "Hà Nội";
    }
    if (lowerAddr.contains("đà nẵng")) {
      return "Đà Nẵng";
    }
    return "";
  }

  // --- LẤY DỮ LIỆU & CẬP NHẬT STATE ---
  Future<void> fetchAndPrepareData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/users/profile',
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
          _userProfile = UserProfile.fromJson(data['data']);
        }
      }
    } catch (e) {
      print("Lỗi checkout VM: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder({
    required String name,
    required String phone,
    required String address,
    required String note,
    required String paymentMethod,
    required CartViewModel cartViewModel,
    String? promotionCode,
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
          'MaKhuyenMai': promotionCode,
        }),
      );

      final data = jsonDecode(response.body);

      // Backend trả về status 200 và error: false là thành công
      if (response.statusCode == 200 && data['error'] == false) {
        // 1. Refresh giỏ hàng
        await cartViewModel.fetchCart();

        // 2. Kiểm tra link thanh toán (nếu là Visa/PayOS)
        if (paymentMethod == 'qr' && data['checkoutUrl'] != null) {
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
