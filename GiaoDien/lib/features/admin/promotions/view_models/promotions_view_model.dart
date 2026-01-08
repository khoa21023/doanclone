import 'package:flutter/material.dart';
import '../../../../data/models/promotion.dart';
import '../../../../data/services/mock_data.dart';

class PromotionsViewModel extends ChangeNotifier {
  List<Promotion> _promotions = [];

  List<Promotion> get promotions => _promotions;

  // Load danh sách ban đầu
  void loadPromotions() {
    _promotions = MockData.promotions;
    notifyListeners();
  }

  // Thêm khuyến mãi
  void addPromotion(Promotion promo) {
    MockData.addPromotion(promo);
    loadPromotions(); // Refresh lại list
  }

  // Xóa khuyến mãi
  void deletePromotion(String id) {
    MockData.deletePromotion(id);
    loadPromotions();
  }

  // Bật/Tắt khuyến mãi
  void togglePromotion(String id) {
    MockData.togglePromotion(id);
    loadPromotions();
  }
}
