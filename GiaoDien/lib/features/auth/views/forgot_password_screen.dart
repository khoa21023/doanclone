import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/forgot_password_view_model.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đặt lại mật khẩu"),
          elevation: 0,
          backgroundColor: Colors.blue.shade50,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.blue.shade100],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Consumer<ForgotPasswordViewModel>(
                    builder: (context, viewModel, child) {
                      // Nếu đã đổi thành công -> Hiện thông báo
                      return viewModel.submitted
                          ? _buildSuccessView(context)
                          : _buildFormView(context, viewModel);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Giao diện Form nhập liệu
  Widget _buildFormView(
    BuildContext context,
    ForgotPasswordViewModel viewModel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhập email và mật khẩu mới để khôi phục tài khoản.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),

        // 1. Nhập Email
        const Text("Email", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'email@vidu.com',
            prefixIcon: Icon(Icons.mail_outline, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Nhập Mật khẩu mới
        const Text(
          "Mật khẩu mới",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),

        // 3. Xác nhận mật khẩu mới
        const Text(
          "Nhập lại mật khẩu",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_reset, color: Colors.grey),
          ),
        ),

        // Hiển thị lỗi từ API hoặc Validate
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () {
                    // Validate cơ bản tại Client
                    if (_newPasswordController.text !=
                        _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mật khẩu xác nhận không khớp!"),
                        ),
                      );
                      return;
                    }
                    if (_newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mật khẩu phải trên 6 ký tự!"),
                        ),
                      );
                      return;
                    }

                    // Gọi hàm xử lý
                    viewModel.resetPassword(
                      email: _emailController.text,
                      newPassword: _newPasswordController.text,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: viewModel.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  // Giao diện Thông báo thành công
  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Thành công!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mật khẩu của bạn đã được cập nhật.\nHãy đăng nhập lại.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Quay về màn hình Login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Quay về Đăng nhập',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
