import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/admin_order_detail_view_model.dart';
import '../../../../data/models/order.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  final Order order;
  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // 1. Cung cấp ViewModel cho màn hình này
    return ChangeNotifierProvider(
      create: (_) => AdminOrderDetailViewModel(order),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chi tiết đơn hàng"),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),
        body: Consumer<AdminOrderDetailViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Progress Bar
                  _buildProgressBar(viewModel.currentStep),
                  const SizedBox(height: 24),

                  // Customer Info
                  _buildSectionTitle("Thông tin khách hàng"),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xFF2563EB),
                      ),
                      title: Text(viewModel.order.userName),
                      subtitle: Text(viewModel.order.userEmail),
                    ),
                  ),

                  // Payment Info
                  const SizedBox(height: 16),
                  _buildSectionTitle("Thanh toán"),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.credit_card,
                        color: Color(0xFF2563EB),
                      ),
                      title: Text(viewModel.order.paymentMethod),
                      trailing: Text(
                        '${viewModel.order.total} VND',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Items List
                  const SizedBox(height: 16),
                  _buildSectionTitle("Sản phẩm"),
                  ...viewModel.order.items.map(
                    (item) => Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.smartphone),
                        ),
                        title: Text(item.productName),
                        subtitle: Text('${item.quantity} x ${item.price} VND'),
                        trailing: Text(
                          '${item.quantity * item.price} VND',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons (Logic hiển thị nút dựa trên status từ VM)
                  if (viewModel.currentStatus == 'placed')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          viewModel.updateStatus('processing');
                          _showSnackBar(
                            context,
                            'Đã duyệt & bắt đầu giao hàng',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Duyệt & Giao hàng"),
                      ),
                    ),

                  if (viewModel.currentStatus == 'processing')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          viewModel.updateStatus('completed');
                          _showSnackBar(context, 'Đã xác nhận giao thành công');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Xác nhận đã giao thành công"),
                      ),
                    ),

                  if (viewModel.currentStatus == 'completed')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Đơn hàng đã hoàn tất",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
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
