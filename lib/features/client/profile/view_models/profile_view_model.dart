import 'package:flutter/material.dart';
import '../../../../data/models/user_profile.dart';

class ProfileViewmodel extends ChangeNotifier{
  bool isEditingProfile = false;
  bool isChangingPassword = false;

  UserProfile _profile;
  ProfileViewmodel():
  _profile= UserProfile(
    name: "Nguyễn Văn A",
    email: "user@example.com",
    phone: "0123456789",
    address: "65 Huỳnh Thúc Kháng, Sài Gòn, Tp HCM"
  );

  UserProfile get profile => _profile;

  void startEditProfile(){
    isEditingProfile = true;

    notifyListeners();
  }
  void cancelEditProfile(){
    isEditingProfile= false;
    notifyListeners();
  }
  void saveProfile({
    required String name,
    required String email,
    required String phone,
    required String address
  }){
    final profile = UserProfile(
      name: name,
      email: email,
      phone: phone,
      address: address,
    );
    _profile = profile;
    isEditingProfile = false;
    notifyListeners();
  }
  void startChangePassword(){
    isChangingPassword = true;
    notifyListeners();
  }
  void cancelChangePassword(){
    isChangingPassword = false;
    notifyListeners();
  }
}