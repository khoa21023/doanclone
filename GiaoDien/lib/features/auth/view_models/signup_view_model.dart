import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String phone, // Đã bổ sung phone
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Validate phía Client trước
    if (password != confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validate Phone sơ bộ ở client
    if (phone.length != 10) {
      _errorMessage = 'Số điện thoại phải có đúng 10 số';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 2. Gọi API
    try {
      // LƯU Ý:
      // - Nếu chạy máy ảo Android: dùng 10.0.2.2
      // - Nếu chạy máy ảo iOS: dùng localhost
      // - Nếu chạy trên điện thoại thật: dùng IP Wifi của máy tính (VD: 192.168.1.10)
      final url = Uri.parse('http://10.0.2.2:3000/api/users/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': name, // API yêu cầu key là "fullName"
          'phone': phone,
          'address': '', // Tạm thời để trống vì UI chưa có
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Đăng ký thành công
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Lỗi từ server trả về (VD: Email tồn tại, validation sai...)
        _errorMessage = data['message'] ?? 'Đăng ký thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Lỗi mạng hoặc lỗi server sập
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
