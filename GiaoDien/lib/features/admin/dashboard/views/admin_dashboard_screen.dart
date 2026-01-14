import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_models/admin_dashboard_view_model.dart';
import '../../../../data/models/order.dart';
import '../../order/views/admin_order_detail_screen.dart';
import '../../promotions/views/promotions_screen.dart';
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

    // Tự động load dữ liệu khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardViewModel>(context, listen: false).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format tiền tệ
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 48) / 2;
    double itemHeight = 100.0;
    double aspectRatio = itemWidth / itemHeight;

    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel()..loadOrders(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Đăng xuất',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Đăng xuất"),
                        content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Hủy"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx); // Tắt bảng hỏi

                              // Hiển thị Loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              try {
                                // BÂY GIỜ DÒNG NÀY SẼ CHẠY NGON LÀNH (Vì context đã đúng)
                                await context
                                    .read<AdminDashboardViewModel>()
                                    .logout();

                                if (context.mounted) {
                                  Navigator.pop(context); // Tắt loading
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                // Phòng hờ nếu vẫn lỗi thì tắt loading đi để không bị treo
                                if (context.mounted) Navigator.pop(context);
                                print("Lỗi: $e");
                              }
                            },
                            child: const Text(
                              "Đồng ý",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
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
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
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
                          onPressed: () => viewModel.loadOrders(),
                          child: const Text("Thử lại"),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // ================== TAB 1: TỔNG QUAN ==================
                    RefreshIndicator(
                      onRefresh: viewModel.loadOrders,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thống kê
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
                            // Menu
                            const Text(
                              'Quản lý nhanh',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMenuCard(
                              context,
                              title: "Chương trình Khuyến mãi",
                              subtitle: "Tạo voucher, giảm giá...",
                              icon: Icons.local_offer_outlined,
                              color: Colors.pink,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PromotionsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // Đơn mới nhất
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
                                .map(
                                  (order) => _buildOrderCard(context, order),
                                ),
                          ],
                        ),
                      ),
                    ),

                    // ================== TAB 2: DANH SÁCH ĐƠN HÀNG ==================
                    RefreshIndicator(
                      onRefresh: viewModel.loadOrders,
                      child: viewModel.orders.isEmpty
                          ? const Center(child: Text("Chưa có đơn hàng nào"))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: viewModel.orders.length,
                              itemBuilder: (context, index) {
                                // Hiển thị toàn bộ đơn hàng
                                return _buildOrderCard(
                                  context,
                                  viewModel.orders[index],
                                );
                              },
                            ),
                    ),

                    // ================== TAB 3: QUẢN LÝ SẢN PHẨM ==================
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text("Tính năng Quản lý sản phẩm đang phát triển"),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
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
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color.shade900,
                  ),
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

  Widget _buildOrderCard(BuildContext context, Order order) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        // Thêm hiệu ứng bấm để chuyển sang chi tiết
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Chuyển sang màn hình chi tiết đơn hàng
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminOrderDetailScreen(order: order),
            ),
          ).then((_) {
            // Khi quay lại thì reload để cập nhật trạng thái mới nhất
            Provider.of<AdminDashboardViewModel>(
              context,
              listen: false,
            ).loadOrders();
          });
        },
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.userName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(order.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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

// Widget thẻ Menu chức năng
Widget _buildMenuCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    ),
  );
}
