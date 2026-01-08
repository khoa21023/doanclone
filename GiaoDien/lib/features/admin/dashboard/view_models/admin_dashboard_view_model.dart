import 'package:flutter/material.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/mock_data.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  List<Order> _orders = [];

  // Getter để View truy cập danh sách đơn hàng
  List<Order> get orders => _orders;

  // Logic load dữ liệu
  void loadOrders() {
    // Trong thực tế chỗ này sẽ gọi API (async/await)
    _orders = MockData.orders;
    notifyListeners(); // Báo cho View cập nhật lại giao diện
  }

  // Helper lọc đơn hàng theo trạng thái
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // --- Các Getter tính toán thống kê ---

  double get totalRevenue {
    return _orders.fold(0.0, (sum, order) => sum + order.total);
  }

  int get totalOrders => _orders.length;

  int get placedCount => _orders.where((o) => o.status == 'placed').length;

  int get processingCount =>
      _orders.where((o) => o.status == 'processing').length;

  int get completedCount =>
      _orders.where((o) => o.status == 'completed').length;
}
