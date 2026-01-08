import 'package:flutter/material.dart';
import '../../../../data/services/mock_data.dart';

class SignupViewModel extends ChangeNotifier {
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

  // Logic Đăng ký
  Future<bool> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Validate dữ liệu
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

    // 2. Giả lập delay API
    await Future.delayed(const Duration(seconds: 1));

    // 3. Gọi MockData để lưu user
    bool success = MockData.register(email, password, name);

    if (!success) {
      _errorMessage = 'Email này đã tồn tại!';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true; // Thành công
  }
}
