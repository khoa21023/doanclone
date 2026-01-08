import 'package:flutter/material.dart';
import '../../../../data/models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  UserProfile? _user;
  bool _isLoading = false;

  UserProfile? get user => _user;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _user = UserProfile(
      id: '1',
      name: 'Nguyễn Văn A',
      email: 'client@gmail.com',
      phone: '0909123456',
      address: 'Ninh Kiều, Cần Thơ',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    );

    _isLoading = false;
    notifyListeners();
  }
}