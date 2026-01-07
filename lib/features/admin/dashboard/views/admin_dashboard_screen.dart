import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/admin_dashboard_view_model.dart';
import '../../promotions/views/promotions_screen.dart';
import '../../order/views/admin_order_detail_screen.dart';
import '../../../../data/models/order.dart';
import '../../../auth/views/login_screen.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tính toán tỷ lệ để thẻ luôn có chiều cao hợp lý (~110px)
    // Công thức: (Chiều rộng màn hình - Padding) / (Số cột * Chiều cao mong muốn)
    double screenWidth = MediaQuery.of(context).size.width;
    double itemHeight = 110.0; // Chiều cao cố định mong muốn cho mỗi thẻ
    double itemWidth =
        (screenWidth - 32 - 12) /
        2; // Trừ padding (16*2) và khoảng cách giữa các cột (12)
    double aspectRatio = itemWidth / itemHeight;

    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel()..loadOrders(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2563EB),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Mobile Tech CT',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PromotionsScreen()),
              ),
              icon: const Icon(Icons.local_offer, color: Colors.white),
              label: const Text(
                'Khuyến mãi',
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.white,
              tooltip: "Đăng xuất",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Đăng xuất"),
                      content: const Text(
                        "Bạn có chắc chắn muốn đăng xuất quyền Admin?",
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Hủy"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text(
                            "Đồng ý",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            // 1. Đóng dialog
                            Navigator.of(context).pop();

                            // 2. Xóa hết stack và về Login
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Consumer<AdminDashboardViewModel>(
              builder: (context, viewModel, _) {
                return TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: [
                    Tab(text: 'Đã đặt (${viewModel.placedCount})'),
                    Tab(text: 'Đang giao (${viewModel.processingCount})'),
                    Tab(text: 'Đã giao (${viewModel.completedCount})'),
                  ],
                );
              },
            ),
          ),
        ),
        body: Consumer<AdminDashboardViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Container chứa 4 thẻ thống kê
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: GridView.count(
                    crossAxisCount: 2, // 2 cột
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true, // Co gọn lại vừa đủ nội dung
                    physics:
                        const NeverScrollableScrollPhysics(), // Không cuộn riêng lẻ
                    childAspectRatio:
                        aspectRatio, // <-- SỬ DỤNG TỶ LỆ ĐỘNG ĐÃ TÍNH
                    children: [
                      _buildStatCard(
                        'Tổng đơn hàng',
                        '${viewModel.totalOrders}',
                        Icons.inventory_2_outlined,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Doanh thu',
                        '${viewModel.totalRevenue.toStringAsFixed(0)} \$',
                        Icons.attach_money,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Đơn hàng mới',
                        '${viewModel.placedCount}',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Đang xử lý',
                        '${viewModel.processingCount}',
                        Icons.local_shipping_outlined,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),

                // Danh sách đơn hàng bên dưới
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(context, viewModel, 'placed'),
                      _buildOrderList(context, viewModel, 'processing'),
                      _buildOrderList(context, viewModel, 'completed'),
                    ],
                  ),
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
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    AdminDashboardViewModel viewModel,
    String status,
  ) {
    final orders = viewModel.getOrdersByStatus(status);
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              "Không có đơn hàng nào",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminOrderDetailScreen(order: order),
              ),
            );
            viewModel.loadOrders();
          },
          child: _buildOrderCard(context, order, status),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, String status) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.userName,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '${order.total} VND',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            if (order.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${order.items[0].quantity}x ${order.items[0].productName}${order.items.length > 1 ? '...' : ''}",
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Xem chi tiết →',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;
    switch (status) {
      case 'placed':
        bgColor = Colors.yellow.shade100;
        textColor = Colors.orange.shade800;
        text = 'Đã đặt';
        break;
      case 'processing':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        text = 'Đang giao';
        break;
      case 'completed':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        text = 'Đã giao';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.black;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
