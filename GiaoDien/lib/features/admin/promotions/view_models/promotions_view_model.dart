import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/promotion.dart';

class PromotionsViewModel extends ChangeNotifier {
  List<Promotion> _promotions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- STATE CỦA FORM THÊM MỚI (Move từ View sang) ---
  DateTime _tempStartDate = DateTime.now();
  DateTime _tempEndDate = DateTime.now().add(const Duration(days: 7));

  // Getters
  List<Promotion> get promotions => _promotions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get tempStartDate => _tempStartDate;
  DateTime get tempEndDate => _tempEndDate;

  // --- CÁC HÀM QUẢN LÝ STATE FORM ---

  // 1. Reset form về mặc định
  void resetForm() {
    _tempStartDate = DateTime.now();
    _tempEndDate = DateTime.now().add(const Duration(days: 7));
    _errorMessage = null;
    notifyListeners();
  }

  // 2. Cập nhật ngày tháng từ View chọn
  void updateDate({DateTime? start, DateTime? end}) {
    if (start != null) _tempStartDate = start;
    if (end != null) _tempEndDate = end;
    notifyListeners();
  }

  // --- LOGIC API ---

  Future<void> loadPromotions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/promotions',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> listData = data['data'];
          _promotions = listData.map((e) => Promotion.fromJson(e)).toList();
        } else {
          _errorMessage = data['message'] ?? "Lấy dữ liệu thất bại";
        }
      } else {
        _errorMessage =
            "Lỗi server: ${response.statusCode} - ${response.reasonPhrase}";
        print(response.body);
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Hàm tạo khuyến mãi (Nhận String từ View, tự Parse và Validate)
  Future<bool> createPromotion({
    required String code,
    required String amountStr,
    required String minOrderStr,
    required String qtyStr,
  }) async {
    _errorMessage = null;

    // --- Validate Logic nằm tại ViewModel ---
    if (code.isEmpty || amountStr.isEmpty || qtyStr.isEmpty) {
      _errorMessage = "Vui lòng nhập đủ Mã, Số tiền và Số lượng";
      notifyListeners();
      return false;
    }

    double amount = double.tryParse(amountStr) ?? 0;
    double minOrder = double.tryParse(minOrderStr) ?? 0;
    int qty = int.tryParse(qtyStr) ?? 0;

    if (amount <= 0 || qty < 0) {
      _errorMessage = "Số tiền và số lượng phải hợp lệ";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/promotions/add',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'MaCode': code,
          'SoTienGiam': amount,
          'DonToiThieu': minOrder,
          'SoLuong': qty,
          'NgayBatDau': _tempStartDate.toIso8601String(), // Lấy từ State của VM
          'NgayKetThuc': _tempEndDate.toIso8601String(), // Lấy từ State của VM
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadPromotions();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Thêm thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Lỗi: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Xóa khuyến mãi
  Future<void> deletePromotion(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/promotions/remove/$id',
      );

      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _promotions.removeWhere((p) => p.id == id);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}
