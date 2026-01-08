import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _submitted = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get submitted => _submitted;

  Future<void> sendResetLink(String email) async {
    _isLoading = true;
    notifyListeners();

    // Giả lập delay API
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    _submitted = true; // Chuyển trạng thái sang "Đã gửi"
    notifyListeners();
  }

  // Reset lại trạng thái để nếu user quay lại màn hình này thì nó như mới
  void reset() {
    _isLoading = false;
    _submitted = false;
    notifyListeners();
  }
}
