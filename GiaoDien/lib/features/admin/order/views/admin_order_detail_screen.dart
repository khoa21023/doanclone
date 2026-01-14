import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Nhớ thêm intl vào pubspec.yaml
import '../view_models/admin_order_detail_view_model.dart';
import '../../../../data/models/order.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  final Order order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminOrderDetailViewModel(order),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Đơn hàng #${order.id}"),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),
        body: Consumer<AdminOrderDetailViewModel>(
          builder: (context, viewModel, child) {
            // Hiển thị loading trùm màn hình khi đang gọi API update
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Thanh trạng thái
                      _buildProgressBar(viewModel.currentStep),
                      const SizedBox(height: 24),

                      // 2. Thông tin khách hàng
                      _buildSectionTitle("Thông tin giao hàng"),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.person,
                                "Khách hàng",
                                viewModel.order.userName,
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.email,
                                "Email",
                                viewModel.order.userEmail.isNotEmpty
                                    ? viewModel.order.userEmail
                                    : "Không có",
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.location_on,
                                "Địa chỉ",
                                viewModel.order.address.isNotEmpty
                                    ? viewModel.order.address
                                    : "Tại cửa hàng",
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.payment,
                                "Thanh toán",
                                viewModel.order.paymentMethod,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Danh sách sản phẩm (Lấy từ order.items)
                      _buildSectionTitle("Sản phẩm đã mua"),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.order.items.length,
                          separatorBuilder: (ctx, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = viewModel.order.items[index];
                            final currencyFormat = NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: 'đ',
                            );
                            return ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ), // Có thể thay bằng Image.network(item.imageUrl) nếu Model có
                              ),
                              title: Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text("x${item.quantity}"),
                              trailing: Text(
                                currencyFormat.format(
                                  item.price * item.quantity,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 4. Tổng tiền
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng cộng:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: 'đ',
                            ).format(viewModel.order.total),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // 5. Nút bấm hành động (Action Buttons)
                      _buildActionButtons(context, viewModel),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Loading Overlay
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Widget Buttons xử lý chuyển trạng thái ---
  Widget _buildActionButtons(
    BuildContext context,
    AdminOrderDetailViewModel viewModel,
  ) {
    // Nếu đơn đã hủy hoặc hoàn tất -> Không hiện nút
    if (viewModel.currentStatus == 'cancelled' ||
        viewModel.currentStatus == 'completed') {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Đơn hàng ${viewModel.currentStatus == 'completed' ? 'đã hoàn tất' : 'đã hủy'}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        // Nút Hủy đơn (Luôn hiện nếu chưa hoàn tất)
        Expanded(
          child: OutlinedButton(
            onPressed: () => _confirmUpdate(
              context,
              viewModel,
              'cancelled',
              "Hủy đơn hàng này?",
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("Hủy đơn"),
          ),
        ),
        const SizedBox(width: 16),

        // Nút chuyển trạng thái tiếp theo
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (viewModel.currentStatus == 'placed') {
                _confirmUpdate(
                  context,
                  viewModel,
                  'processing',
                  "Xác nhận giao hàng?",
                );
              } else if (viewModel.currentStatus == 'processing') {
                _confirmUpdate(
                  context,
                  viewModel,
                  'completed',
                  "Xác nhận đã giao thành công?",
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              viewModel.currentStatus == 'placed'
                  ? "Xác nhận giao"
                  : "Hoàn tất đơn",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Hàm hiển thị hộp thoại xác nhận
  void _confirmUpdate(
    BuildContext context,
    AdminOrderDetailViewModel viewModel,
    String nextStatus,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Đóng popup
              bool success = await viewModel.updateStatus(nextStatus);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cập nhật thành công!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? "Lỗi"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              "Đồng ý",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    // (Giữ nguyên code phần _buildProgressBar của bạn ở đây, code bạn viết phần này ổn rồi)
    // Nếu bạn muốn tôi paste lại thì báo nhé, nhưng để tiết kiệm dòng tin nhắn tôi lược bớt phần UI này.
    return Row(
      children: [
        _buildStep(1, "Đã đặt", currentStep >= 1),
        Expanded(
          child: Divider(
            color: currentStep >= 2 ? Colors.green : Colors.grey.shade300,
            thickness: 2,
          ),
        ),
        _buildStep(2, "Đang giao", currentStep >= 2),
        Expanded(
          child: Divider(
            color: currentStep >= 3 ? Colors.green : Colors.grey.shade300,
            thickness: 2,
          ),
        ),
        _buildStep(3, "Đã giao", currentStep >= 3),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}
