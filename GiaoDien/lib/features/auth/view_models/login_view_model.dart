import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Hàm login trả về String? (là Role của user) thay vì bool
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Gọi API (Sử dụng URL Render của bạn)
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/users/login',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 2. Đăng nhập thành công -> Lưu Token & Info
        String token = data['token'];
        Map<String, dynamic> user = data['user'];
        String role = user['role']; // Lấy vai trò (Admin/Customer)

        // Lưu vào bộ nhớ máy để dùng cho các màn hình sau
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', user['id']);
        await prefs.setString('userRole', role);
        await prefs.setString('userName', user['name']);

        _isLoading = false;
        notifyListeners();

        return role; // Trả về role để UI chuyển trang
      } else {
        // Lỗi từ server (VD: Sai mật khẩu)
        _errorMessage = data['message'] ?? 'Đăng nhập thất bại';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
