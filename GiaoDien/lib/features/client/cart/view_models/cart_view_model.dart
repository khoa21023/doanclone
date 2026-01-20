import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/cart_model.dart';
import '../../../../data/models/promotion.dart';

class CartViewModel extends ChangeNotifier {
  List<CartItem> _items = [];
  CartSummary _summary = CartSummary(subTotal: 0, shippingFee: 0, total: 0);
  bool _isLoading = false;
  String? _errorMessage;
  List<Promotion> _promotions = []; // Danh sách mã lấy từ server
  Promotion? _selectedPromotion;

  List<CartItem> get items => _items;
  CartSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Promotion> get promotions => _promotions;
  Promotion? get selectedPromotion => _selectedPromotion;

  // Lấy số lượng item để hiện Badge trên icon giỏ hàng
  int get itemCount => _items.length;

  // --- TÍNH TIỀN ---
  // 1. Lấy số tiền được giảm
  double get discountAmount {
    if (_selectedPromotion == null) return 0;
    // Kiểm tra lại điều kiện đơn tối thiểu
    if (_summary.subTotal < _selectedPromotion!.minOrderValue) {
      return 0;
    }
    return _selectedPromotion!.discountAmount;
  }

  // 2. Tính tổng cuối cùng
  double get totalAfterDiscount {
    double finalTotal = _summary.total - discountAmount;
    return finalTotal > 0 ? finalTotal : 0; // Không để âm tiền
  }

  // --- LẤY DANH SÁCH KHUYẾN MÃI ---
  Future<void> fetchPromotions() async {
    try {
      // 1. Lấy Token từ bộ nhớ máy
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/promotions',
      );

      final response = await http.get(
        url,
        // 2. Thêm Header chứa Token để Backend cho phép đi qua
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'];
          _promotions = list.map((e) => Promotion.fromJson(e)).toList();

          // Lọc chỉ lấy mã còn hạn
          // _promotions = _promotions.where((p) => p.isValid).toList();
          notifyListeners();
        }
      } else {
        print("Lỗi tải khuyến mãi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối khuyến mãi: $e");
    }
  }

  // --- CHỌN MÃ ---
  bool applyPromotion(Promotion promo) {
    print("Đang thử mã: ${promo.code}");
    print(
      "Giá trị đơn: ${_summary.subTotal} - Đơn tối thiểu: ${promo.minOrderValue}",
    );
    print("Số tiền giảm: ${promo.discountAmount}");

    // Kiểm tra điều kiện đơn tối thiểu
    if (_summary.subTotal < promo.minOrderValue) {
      _errorMessage = "Đơn hàng chưa đủ ${promo.minOrderValue}đ để dùng mã này";
      notifyListeners();
      return false; // Áp dụng thất bại
    }

    // Nếu đang chọn chính mã đó thì bỏ chọn
    if (_selectedPromotion?.id == promo.id) {
      _selectedPromotion = null;
    } else {
      _selectedPromotion = promo;
    }
    _errorMessage = null; // Xóa lỗi nếu có
    notifyListeners();
    return true; // Thành công
  }

  // --- LẤY GIỎ HÀNG ---
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('https://mobile-tech-ct.onrender.com/api/cart');

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
          // Parse danh sách items
          final List<dynamic> listItems = data['data']['items'];
          _items = listItems.map((e) => CartItem.fromJson(e)).toList();

          // Parse thông tin tổng tiền
          _summary = CartSummary.fromJson(data['data']['summary']);

          // RESET mã giảm giá nếu tổng đơn thay đổi và không còn đủ điều kiện
          if (_selectedPromotion != null &&
              _summary.subTotal < _selectedPromotion!.minOrderValue) {
            _selectedPromotion = null;
          }
        }
      } else {
        _errorMessage = "Không tải được giỏ hàng";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. THÊM VÀO GIỎ (Gọi từ Home hoặc Detail)
  Future<bool> addToCart(String productId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('https://mobile-tech-ct.onrender.com/api/cart/add');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Thêm thành công thì tải lại giỏ hàng để cập nhật số lượng badge
        fetchCart();
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi thêm giỏ hàng: $e");
      return false;
    }
  }

  // 3. CẬP NHẬT SỐ LƯỢNG (Tăng/Giảm)
  Future<void> updateQuantity(String cartId, int newQuantity) async {
    // Optimistic Update: Cập nhật UI trước cho mượt
    final index = _items.indexWhere((item) => item.cartId == cartId);
    if (index != -1) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/cart/update-quantity',
      );

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'cartId': cartId, 'quantity': newQuantity}),
      );

      // Gọi lại fetchCart để tính toán lại tổng tiền chuẩn từ server
      await fetchCart();
    } catch (e) {
      print("Lỗi update quantity: $e");
      fetchCart(); // Revert lại nếu lỗi
    }
  }

  // 4. XÓA SẢN PHẨM
  Future<void> removeItem(String cartId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse(
        'https://mobile-tech-ct.onrender.com/api/cart/remove/$cartId',
      );

      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Xóa item khỏi list local ngay lập tức
        _items.removeWhere((item) => item.cartId == cartId);
        notifyListeners();
        // Tải lại để cập nhật tổng tiền
        fetchCart();
      }
    } catch (e) {
      print("Lỗi xóa item: $e");
    }
  }
}
