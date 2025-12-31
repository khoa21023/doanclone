import 'package:flutter/material.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/mock_data.dart';

class AdminOrderDetailViewModel extends ChangeNotifier {
  final Order _order; // Giữ tham chiếu đến order gốc
  late String _currentStatus;

  AdminOrderDetailViewModel(this._order) {
    _currentStatus = _order.status;
  }

  // Getter
  Order get order => _order;
  String get currentStatus => _currentStatus;

  // Logic cập nhật trạng thái
  void updateStatus(String newStatus) {
    _currentStatus = newStatus;

    // Gọi xuống lớp dữ liệu
    MockData.updateOrderStatus(_order.id, newStatus);

    // Cập nhật UI
    notifyListeners();
  }

  // Helper để xác định bước hiện tại cho thanh tiến trình (Progress Bar)
  int get currentStep {
    if (_currentStatus == 'processing') return 2;
    if (_currentStatus == 'completed') return 3;
    return 1; // Default: placed
  }
}
