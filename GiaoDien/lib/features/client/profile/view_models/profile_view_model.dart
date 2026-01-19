import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  UserProfile? _profile; // Có thể null khi chưa tải xong
  bool _isLoading = false;
  bool _isEditingProfile = false;
  bool _isChangingPassword = false;
  String? _errorMessage;

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isEditingProfile => _isEditingProfile;
  bool get isChangingPassword => _isChangingPassword;
  String? get errorMessage => _errorMessage;

  // --- QUẢN LÝ TRẠNG THÁI UI ---
  void startEditProfile() {
    _isEditingProfile = true;
    notifyListeners();
  }

  void cancelEditProfile() {
    _isEditingProfile = false;
    notifyListeners();
  }

  void startChangePassword() {
    _isChangingPassword = true;
    notifyListeners();
  }

  void cancelChangePassword() {
    _isChangingPassword = false;
    notifyListeners();
  }

  // --- 1. LẤY THÔNG TIN PROFILE ---
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      // Giả sử API lấy thông tin user hiện tại là /api/users/profile
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

      print("API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _profile = UserProfile.fromJson(data['data']);
        }
      } else {
        _errorMessage = "Không thể tải thông tin cá nhân";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. CẬP NHẬT THÔNG TIN ---
  Future<bool> updateProfile(String name, String phone, String address) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/users/update-profile',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'HoTen': name,
          'SoDienThoai': phone,
          'DiaChi': address,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Cập nhật thành công -> Tải lại data mới
        await fetchProfile();
        _isEditingProfile = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? "Cập nhật thất bại";
        return false;
      }
    } catch (e) {
      _errorMessage = "Lỗi: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 3. ĐỔI MẬT KHẨU ---
  Future<bool> changePassword(String currentPass, String newPass) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/users/change-password',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'MatKhauCu': currentPass, 'MatKhauMoi': newPass}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _isChangingPassword = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? "Đổi mật khẩu thất bại";
        return false;
      }
    } catch (e) {
      _errorMessage = "Lỗi: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
