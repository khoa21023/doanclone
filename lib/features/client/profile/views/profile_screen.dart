import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  void _fillProfile(UserProfile p) {
    _nameController.text = p.name;
    _emailController.text = p.email;
    _phoneController.text = p.phone;
    _addressController.text = p.address;
  }

  void _clearPassword() {
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();
    setState(() {
      _showCurrentPassword = false;
      _showNewPassword = false;
      _showConfirmPassword = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewmodel(),
      child: Scaffold(
        backgroundColor: Color(0xFFF0F9FF),
        appBar: AppBar(
          title: const Text("Hồ sơ của tôi"),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),
        body: Consumer<ProfileViewmodel>(
          builder: (context, vm, child) {
            _fillProfile(vm.profile);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCard(
                    title: "Thông tin cá nhân",
                    actionText:
                        vm.isEditingProfile ? null : "Chỉnh sửa",
                    onAction:
                        vm.isEditingProfile ? null : vm.startEditProfile,
                    child: Form(
                      key: _profileFormKey,
                      child: Column(
                        children: [
                          _buildProfileField(
                            icon: Icons.person,
                            label: "Họ và tên",
                            controller: _nameController,
                            enabled: vm.isEditingProfile,
                          ),
                          _buildProfileField(
                            icon: Icons.email,
                            label: "Email",
                            controller: _emailController,
                            enabled: vm.isEditingProfile,
                          ),
                          _buildProfileField(
                            icon: Icons.phone,
                            label: "Số điện thoại",
                            controller: _phoneController,
                            enabled: vm.isEditingProfile,
                          ),
                          _buildProfileField(
                            icon: Icons.location_on,
                            label: "Địa chỉ",
                            controller: _addressController,
                            enabled: vm.isEditingProfile,
                          ),
                          if (vm.isEditingProfile) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.grey
                                    ),
                                    onPressed: () {
                                      _profileFormKey.currentState?.reset();
                                      _fillProfile(vm.profile);
                                      vm.cancelEditProfile();
                                    },
                                    child: const Text("Huỷ bỏ"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2563EB),
                                      foregroundColor: Colors.white
                                    ),
                                    onPressed: () {
                                      if (_profileFormKey.currentState!
                                          .validate()) {
                                        vm.saveProfile(
                                          UserProfile(
                                            name: _nameController.text,
                                            email: _emailController.text,
                                            phone: _phoneController.text,
                                            address:
                                                _addressController.text,
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save_outlined),
                                        SizedBox(width: 6),
                                        Text("Lưu thay đổi")
                                      ],
                                    ),
                                  )
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Bảo mật",
                    actionText: vm.isChangingPassword
                        ? null
                        : "Đổi mật khẩu",
                    onAction: vm.isChangingPassword
                        ? null
                        : vm.startChangePassword,
                    child: vm.isChangingPassword
                        ? Form(
                            key: _passwordFormKey,
                            child: Column(
                              children: [
                                _buildPasswordField(
                                  label: "Mật khẩu hiện tại",
                                  controller:
                                      _currentPassController,
                                  visible: _showCurrentPassword,
                                  onToggleVisibility: () => setState(
                                      () => _showCurrentPassword =
                                          !_showCurrentPassword),
                                ),
                                _buildPasswordField(
                                  label: "Mật khẩu mới",
                                  controller: _newPassController,
                                  visible: _showNewPassword,
                                  onToggleVisibility: () =>
                                      setState(() => _showNewPassword = !_showNewPassword),
                                ),
                                _buildPasswordField(
                                  label: "Nhập lại mật khẩu mới",
                                  controller:
                                      _confirmPassController,
                                  visible: _showConfirmPassword,
                                  onToggleVisibility: () => setState(() =>
                                      _showConfirmPassword = !_showConfirmPassword),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.grey
                                        ),
                                        onPressed: () {
                                          _clearPassword();
                                          vm.cancelChangePassword();
                                        },
                                        child: const Text("Huỷ bỏ"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF2563EB),
                                          foregroundColor: Colors.white
                                        ),
                                        onPressed: () {
                                          if (_passwordFormKey
                                              .currentState!
                                              .validate()) {
                                            _clearPassword();
                                            vm.cancelChangePassword();
                                          }
                                        },
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock_outline),
                                            SizedBox(width: 6),
                                            Text("Cập nhật mật khẩu")
                                          ],
                                        )
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        : const Text("Bảo vệ tài khoản bằng mật khẩu mạnh"),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    String? actionText,
    VoidCallback? onAction,
    required Widget child,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (actionText != null)
                  TextButton(
                      onPressed: onAction,
                      child: Text(actionText)),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
  required IconData icon,
  required String label,
  required TextEditingController controller,
  required bool enabled,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        enabled: enabled,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Không được để trống';
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 14),
    ],
  );
}

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
        controller: controller,
        obscureText: !visible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Không được để trống';
          }
          if (controller == _confirmPassController &&
              value != _newPassController.text) {
            return 'Mật khẩu không khớp';
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          fillColor: Colors.white,
          filled: true,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
      const SizedBox(height: 14)
      ]
    );
  }
}
