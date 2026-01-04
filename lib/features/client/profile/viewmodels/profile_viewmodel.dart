import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileViewmodel extends ChangeNotifier{
  bool isEditingProfile = false;
  bool isChangingPassword = false;

  UserProfile profile = UserProfile(
    name: "Nguyễn Văn A",
    email: "user@example.com",
    phone: "0123456789",
    address: "65 Huỳnh Thúc Kháng, Sài Gòn, Tp HCM"
  );
  void startEditProfile(){
    isEditingProfile = true;

    notifyListeners();
  }
  void cancelEditProfile(){
    isEditingProfile= false;
    notifyListeners();
  }
  void saveProfile(UserProfile newProfile){
    profile= newProfile;
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