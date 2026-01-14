import 'package:flutter/material.dart';
import '../../../../data/models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  // Dữ liệu giả lập để hiển thị giao diện
  UserProfile profile = UserProfile(
    id: "01",
    name: "Người dùng",
    email: "user@example.com",
    phone: "0123456789",
    address: "Địa chỉ của bạn",
  );

  bool isEditingProfile = false;
  bool isChangingPassword = false;

  void startEditProfile() {
    isEditingProfile = true;
    notifyListeners();
  }

  void cancelEditProfile() {
    isEditingProfile = false;
    notifyListeners();
  }

  void startChangePassword() {
    isChangingPassword = true;
    notifyListeners();
  }

  void cancelChangePassword() {
    isChangingPassword = false;
    notifyListeners();
  }

  // Tạm thời chưa viết logic Save
  void saveProfile(UserProfile p) {}
}