import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Cần thêm intl vào pubspec.yaml
import '../view_models/admin_dashboard_view_model.dart';
import '../../../../data/models/order.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Tự động load dữ liệu khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardViewModel>(context, listen: false).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    // Tính toán kích thước cho Grid
    double screenWidth = MediaQuery.of(context).size.width;
    // Điều chỉnh aspect ratio để thẻ không bị lỗi layout
    double itemWidth = (screenWidth - 48) / 2; // trừ padding
    double itemHeight = 100.0;
    double aspectRatio = itemWidth / itemHeight;

    return ChangeNotifierProvider(
      create: (_) =>
          AdminDashboardViewModel(), // (Hoặc dùng provider có sẵn từ main)
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2563EB),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                'Admin Portal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            tabs: const [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Đơn hàng'),
              Tab(text: 'Sản phẩm'),
            ],
          ),
        ),
        body: Consumer<AdminDashboardViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: viewModel.loadOrders,
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // --- TAB 1: TỔNG QUAN ---
                RefreshIndicator(
                  onRefresh: viewModel.loadOrders,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: aspectRatio,
                          children: [
                            _buildStatCard(
                              'Doanh thu',
                              currencyFormat.format(viewModel.totalRevenue),
                              Colors.blue,
                              Icons.attach_money,
                            ),
                            _buildStatCard(
                              'Tổng đơn',
                              '${viewModel.totalOrders}',
                              Colors.orange,
                              Icons.shopping_bag_outlined,
                            ),
                            _buildStatCard(
                              'Chờ xác nhận',
                              '${viewModel.placedCount}',
                              Colors.purple,
                              Icons.new_releases_outlined,
                            ),
                            _buildStatCard(
                              'Đang giao',
                              '${viewModel.processingCount}',
                              Colors.teal,
                              Icons.local_shipping_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Đơn hàng mới nhất',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (viewModel.orders.isEmpty)
                          const Text(
                            "Chưa có đơn hàng nào",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ...viewModel.orders
                            .take(5)
                            .map((order) => _buildOrderCard(order)),
                      ],
                    ),
                  ),
                ),

                // --- TAB 2: DANH SÁCH ĐƠN HÀNG ---
                RefreshIndicator(
                  onRefresh: viewModel.loadOrders,
                  child: viewModel.orders.isEmpty
                      ? const Center(child: Text("Chưa có dữ liệu"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: viewModel.orders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(viewModel.orders[index]);
                          },
                        ),
                ),

                // --- TAB 3: SẢN PHẨM ---
                const Center(
                  child: Text("Tính năng quản lý sản phẩm đang phát triển"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    MaterialColor color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color.shade700, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildStatusBadge(order.status, order.statusInVietnamese),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SỬA: Dùng userName thay vì customerName
                    Text(
                      order.userName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    // SỬA: Dùng createdAt thay vì date
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(order.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String code, String label) {
    Color bgColor;
    Color textColor;

    switch (code) {
      case 'placed':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'processing':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'completed':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'cancelled':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
