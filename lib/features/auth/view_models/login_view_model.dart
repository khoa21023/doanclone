import 'package:flutter/material.dart';
import '../../../../data/services/mock_data.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  // Toggle ẩn/hiện mật khẩu
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Logic Đăng nhập
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Giả lập delay API
    await Future.delayed(const Duration(seconds: 1));

    // Gọi MockData
    bool isValidUser = MockData.login(email, password);

    if (!isValidUser) {
      _errorMessage = 'Email hoặc mật khẩu không đúng';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true; // Trả về true để View biết đường chuyển trang
  }
}
