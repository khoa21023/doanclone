import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _submitted = false; // Trạng thái đã đổi thành công chưa
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get submitted => _submitted;
  String? get errorMessage => _errorMessage;

  // Hàm đặt lại mật khẩu (Gọi API)
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // URL API Render của bạn
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/users/reset-password',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword, // Backend yêu cầu key là 'newPassword'
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Thành công -> Chuyển sang màn hình thông báo
        _submitted = true;
        _isLoading = false;
        notifyListeners();
      } else {
        // Lỗi (ví dụ: Email không tồn tại)
        _errorMessage = data['message'] ?? 'Đặt lại mật khẩu thất bại';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset trạng thái để dùng lại màn hình
  void reset() {
    _isLoading = false;
    _submitted = false;
    _errorMessage = null;
    notifyListeners();
  }
}
