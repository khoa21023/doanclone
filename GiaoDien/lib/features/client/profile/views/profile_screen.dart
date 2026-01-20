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

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  // bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    // Gọi API lấy thông tin ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

  // Hàm điền dữ liệu vào ô input
  void _populateControllers(UserProfile? p) {
    if (p != null) {
      // Chỉ cập nhật text nếu controller đang trống hoặc khác dữ liệu gốc
      if (_nameController.text.isEmpty) _nameController.text = p.name;
      if (_emailController.text.isEmpty) _emailController.text = p.email;
      if (_phoneController.text.isEmpty) _phoneController.text = p.phone;
      if (_addressController.text.isEmpty) _addressController.text = p.address;
    }
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
    // Không tạo Provider ở đây nữa, nên tạo ở main.dart hoặc route cha
    // Nhưng nếu bạn muốn tạo cục bộ thì giữ nguyên cũng được.
    return ChangeNotifierProvider(
      create: (_) =>
          ProfileViewModel()..fetchProfile(), // Gọi fetch ngay khi tạo
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
            if (vm.isLoading && vm.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Logic điền dữ liệu: Chỉ điền khi KHÔNG ở chế độ sửa
            if (!vm.isEditingProfile) {
              _populateControllers(vm.profile);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- AVATAR ---
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2563EB),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            // Logic: Nếu có avatarUrl thì hiện, không thì hiện avatar chữ cái
                            backgroundImage:
                                (vm.profile?.avatarUrl != null &&
                                    vm.profile!.avatarUrl!.isNotEmpty)
                                ? NetworkImage(vm.profile!.avatarUrl!)
                                : NetworkImage(
                                    "https://ui-avatars.com/api/?name=${vm.profile?.name ?? 'User'}&background=random&size=128",
                                  ),
                          ),
                        ),
                        // Nút Camera
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: vm.isLoading
                                ? null
                                : () async {
                                    // GỌI HÀM UPLOAD
                                    bool success = await vm.uploadAvatar();
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Đổi ảnh đại diện thành công!",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF2563EB),
                              child: vm.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
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
                    onAction: vm.isEditingProfile
                        ? null
                        : () {
                            // Khi bấm chỉnh sửa, đảm bảo text controller khớp với data hiện tại
                            if (vm.profile != null) {
                              _nameController.text = vm.profile!.name;
                              _phoneController.text = vm.profile!.phone;
                              _addressController.text = vm.profile!.address;
                            }
                            vm.startEditProfile();
                          },
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
                            enabled: false,
                          ), // Email thường không cho sửa
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
                            if (vm.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  vm.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
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
                                    onPressed: vm.isLoading
                                        ? null
                                        : () async {
                                            bool success = await vm
                                                .updateProfile(
                                                  _nameController.text,
                                                  _phoneController.text,
                                                  _addressController.text,
                                                );
                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Cập nhật thành công!",
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                    child: vm.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text("Lưu thay đổi"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- ĐỔI MẬT KHẨU ---
                  _buildCard(
                    title: "Bảo mật",
                    actionText: vm.isChangingPassword ? null : "Đổi mật khẩu",
                    onAction: vm.isChangingPassword
                        ? null
                        : () {
                            _currentPassController.clear();
                            _newPassController.clear();
                            vm.startChangePassword();
                          },
                    child: vm.isChangingPassword
                        ? Column(
                            children: [
                              _buildPasswordField(
                                label: "Mật khẩu hiện tại",
                                controller: _currentPassController,
                                visible: _showCurrentPassword,
                                onToggleVisibility: () => setState(
                                  () => _showCurrentPassword =
                                      !_showCurrentPassword,
                                ),
                              ),
                              _buildPasswordField(
                                label: "Mật khẩu mới",
                                controller: _newPassController,
                                visible: _showNewPassword,
                                onToggleVisibility: () => setState(
                                  () => _showNewPassword = !_showNewPassword,
                                ),
                              ),

                              if (vm.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    vm.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),

                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: vm.cancelChangePassword,
                                      child: const Text("Huỷ"),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2563EB,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: vm.isLoading
                                          ? null
                                          : () async {
                                              if (_currentPassController
                                                      .text
                                                      .isEmpty ||
                                                  _newPassController
                                                      .text
                                                      .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Vui lòng nhập đầy đủ thông tin",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              bool success = await vm
                                                  .changePassword(
                                                    _currentPassController.text,
                                                    _newPassController.text,
                                                  );
                                              if (success && context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Đổi mật khẩu thành công!",
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            },
                                      child: vm.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text("Cập nhật"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Bảo vệ tài khoản bằng mật khẩu mạnh",
                              style: TextStyle(color: Colors.grey),
                            ),
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

  // --- CÁC WIDGET PHỤ GIỮ NGUYÊN ---
  Widget _buildCard({
    required String title,
    String? actionText,
    VoidCallback? onAction,
    required Widget child,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (actionText != null)
                  TextButton(onPressed: onAction, child: Text(actionText)),
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
          style: TextStyle(
            color: enabled ? Colors.black : Colors.black87,
          ), // Chữ vẫn đậm khi disable
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
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
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: IconButton(
              icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
