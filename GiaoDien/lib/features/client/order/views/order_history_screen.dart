import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../client/order/view_models/order_view_model.dart';
import '../../../../data/models/order.dart';
import 'order_detail_screen.dart'; // Đảm bảo đã import trang chi tiết

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi API lấy danh sách đơn hàng khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().fetchMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            "Lịch sử đơn hàng",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black),
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF2563EB),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2563EB),
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Chờ xác nhận"),
              Tab(text: "Đang giao"),
              Tab(text: "Đã giao"),
              Tab(text: "Đã hủy"),
            ],
          ),
        ),
        body: Consumer<OrderViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.orders.isEmpty) {
              return const Center(child: Text("Bạn chưa có đơn hàng nào."));
            }

            return TabBarView(
              children: [
                _buildOrderList(viewModel.orders), // Tất cả
                _buildOrderList(
                  viewModel.orders
                      .where((o) => o.displayStatus == 'Chờ xác nhận')
                      .toList(),
                ),
                _buildOrderList(
                  viewModel.orders
                      .where((o) => o.displayStatus == 'Đang giao')
                      .toList(),
                ),
                _buildOrderList(
                  viewModel.orders
                      .where((o) => o.displayStatus == 'Đã giao')
                      .toList(),
                ),
                _buildOrderList(
                  viewModel.orders
                      .where((o) => o.displayStatus == 'Đã hủy')
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<ClientOrder> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text("Không có đơn hàng trong mục này."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OrderCard(order: orders[index]),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final ClientOrder order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return GestureDetector(
      onTap: () {
        // Chuyển sang màn hình chi tiết khi nhấn vào đơn hàng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: order.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mã đơn: #${order.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                _buildStatusBadge(order.displayStatus, order.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(order.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng thanh toán:",
                  style: TextStyle(color: Colors.black87),
                ),
                Text(
                  currencyFormat.format(order.total),
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Thanh toán: ${order.paymentStatus}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: order.paymentStatus.contains("Đã")
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Xem chi tiết >",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String displayStatus, String rawStatus) {
    Color color = Colors.grey;

    // Tối ưu logic màu sắc dựa trên status
    if (displayStatus == 'Đã hủy') {
      color = Colors.red;
    } else if (displayStatus == 'Đã giao') {
      color = Colors.green;
    } else if (displayStatus == 'Đang giao') {
      color = Colors.blue;
    } else {
      color = Colors.orange; // Chờ xác nhận
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
