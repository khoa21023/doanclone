import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/profile_view_model.dart';
import '../../../../data/models/user_profile.dart';

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
    // Khởi tạo ViewModel ngay tại đây khi vào trang
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9FF),
        appBar: AppBar(
          title: const Text("Hồ sơ của tôi"),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, vm, child) {
            // Đổ dữ liệu mẫu từ VM vào controller
            _fillProfile(vm.profile);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- PHẦN AVATAR (GIỮ TỪ FILE CŨ) ---
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            "https://ui-avatars.com/api/?name=User&background=random",
                          ),
                        ),
                        if (vm.isEditingProfile)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF2563EB),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                onPressed: () {
                                  // Chỗ này để chọn ảnh
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- THÔNG TIN CÁ NHÂN ---
                  _buildCard(
                    title: "Thông tin cá nhân",
                    actionText: vm.isEditingProfile ? null : "Chỉnh sửa",
                    onAction: vm.isEditingProfile ? null : vm.startEditProfile,
                    child: Form(
                      key: _profileFormKey,
                      child: Column(
                        children: [
                          _buildProfileField(icon: Icons.person, label: "Họ và tên", controller: _nameController, enabled: vm.isEditingProfile),
                          _buildProfileField(icon: Icons.email, label: "Email", controller: _emailController, enabled: vm.isEditingProfile),
                          _buildProfileField(icon: Icons.phone, label: "Số điện thoại", controller: _phoneController, enabled: vm.isEditingProfile),
                          _buildProfileField(icon: Icons.location_on, label: "Địa chỉ", controller: _addressController, enabled: vm.isEditingProfile),
                          
                          if (vm.isEditingProfile) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: vm.cancelEditProfile,
                                    child: const Text("Huỷ bỏ"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => vm.cancelEditProfile(),
                                    child: const Text("Lưu thay đổi"),
                                  ),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- BẢO MẬT ---
                  _buildCard(
                    title: "Bảo mật",
                    actionText: vm.isChangingPassword ? null : "Đổi mật khẩu",
                    onAction: vm.isChangingPassword ? null : vm.startChangePassword,
                    child: vm.isChangingPassword
                        ? Column(
                            children: [
                              _buildPasswordField(label: "Mật khẩu hiện tại", controller: _currentPassController, visible: _showCurrentPassword, onToggleVisibility: () => setState(() => _showCurrentPassword = !_showCurrentPassword)),
                              _buildPasswordField(label: "Mật khẩu mới", controller: _newPassController, visible: _showNewPassword, onToggleVisibility: () => setState(() => _showNewPassword = !_showNewPassword)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: OutlinedButton(onPressed: vm.cancelChangePassword, child: const Text("Huỷ"))),
                                  const SizedBox(width: 12),
                                  Expanded(child: ElevatedButton(onPressed: vm.cancelChangePassword, child: const Text("Cập nhật"))),
                                ],
                              )
                            ],
                          )
                        : const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Bảo vệ tài khoản bằng mật khẩu mạnh", style: TextStyle(color: Colors.grey)),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildCard({required String title, String? actionText, VoidCallback? onAction, required Widget child}) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (actionText != null) TextButton(onPressed: onAction, child: Text(actionText)),
          ]),
          const Divider(),
          child,
        ]),
      ),
    );
  }

  Widget _buildProfileField({required IconData icon, required String label, required TextEditingController controller, required bool enabled}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          filled: true,
          fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }

  Widget _buildPasswordField({required String label, required TextEditingController controller, required bool visible, required VoidCallback onToggleVisibility}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: !visible,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(icon: Icon(visible ? Icons.visibility : Icons.visibility_off), onPressed: onToggleVisibility),
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }
}