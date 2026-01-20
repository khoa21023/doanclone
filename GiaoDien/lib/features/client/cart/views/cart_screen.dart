import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_models/cart_view_model.dart';
import '../../checkout/views/checkout_screen.dart';
import '../../../../data/models/promotion.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CartViewModel>();
      vm.fetchCart();
      vm.fetchPromotions();
    });
  }

  // --- HIỆN BOTTOM SHEET CHỌN MÃ ---
  void _showPromotionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<CartViewModel>(
          builder: (context, cart, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chọn Khuyến Mãi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: cart.promotions.isEmpty
                        ? const Center(child: Text("Không có mã giảm giá nào."))
                        : ListView.separated(
                            itemCount: cart.promotions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final promo = cart.promotions[index];
                              final isSelected =
                                  cart.selectedPromotion?.id == promo.id;
                              final currencyFormat = NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: 'đ',
                              );
                              final bool canApply =
                                  cart.summary.subTotal >= promo.minOrderValue;

                              return Opacity(
                                opacity: canApply ? 1.0 : 0.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? Colors.blue.shade50
                                        : Colors.white,
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.confirmation_number_outlined,
                                      color: Color(0xFF2563EB),
                                    ),
                                    title: Text(
                                      promo.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Giảm ${currencyFormat.format(promo.discountAmount)}",
                                        ),
                                        Text(
                                          "Đơn tối thiểu: ${currencyFormat.format(promo.minOrderValue)}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF2563EB),
                                          )
                                        : null,
                                    onTap: () {
                                      if (canApply) {
                                        cart.applyPromotion(promo);
                                        Navigator.pop(
                                          context,
                                        ); // Đóng sheet sau khi chọn
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Chưa đủ điều kiện áp dụng mã này (Tối thiểu ${currencyFormat.format(promo.minOrderValue)})",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2563EB),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Khi kéo xuống, tải lại cả giỏ hàng và khuyến mãi
          final vm = context.read<CartViewModel>();
          await Future.wait([vm.fetchCart(), vm.fetchPromotions()]);
        },
        child: Consumer<CartViewModel>(
          builder: (context, cart, child) {
            if (cart.isLoading && cart.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (cart.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Giỏ hàng trống',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tiếp tục mua sắm"),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // DANH SÁCH SẢN PHẨM
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Ảnh sản phẩm
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  width: 70,
                                  height: 70,
                                  child: const Icon(Icons.image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Thông tin
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(item.price),
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Nút tăng giảm số lượng
                            Column(
                              children: [
                                Row(
                                  children: [
                                    _qtyBtn(Icons.remove, () {
                                      if (item.quantity > 1) {
                                        cart.updateQuantity(
                                          item.cartId,
                                          item.quantity - 1,
                                        );
                                      }
                                    }),
                                    Container(
                                      width: 30,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _qtyBtn(Icons.add, () {
                                      // Kiểm tra tồn kho ở Backend rồi, cứ gửi request thôi
                                      cart.updateQuantity(
                                        item.cartId,
                                        item.quantity + 1,
                                      );
                                    }),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirm(
                                      context,
                                      cart,
                                      item.cartId,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // THANH THANH TOÁN
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.grey.withOpacity(0.1),
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // --- PHẦN CHỌN KHUYẾN MÃI ---
                      InkWell(
                        onTap: () => _showPromotionSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.confirmation_number_outlined,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cart.selectedPromotion != null
                                      ? "Đã áp dụng: ${cart.selectedPromotion!.code}"
                                      : "Chọn Khuyến Mãi / Voucher",
                                  style: TextStyle(
                                    color: cart.selectedPromotion != null
                                        ? Colors.green
                                        : Colors.black87,
                                    fontWeight: cart.selectedPromotion != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _summaryRow(
                        'Tạm tính:',
                        currencyFormat.format(cart.summary.subTotal),
                      ),
                      const SizedBox(height: 8),
                      _summaryRow(
                        'Phí vận chuyển:',
                        currencyFormat.format(cart.summary.shippingFee),
                      ),

                      // --- HIỂN THỊ DÒNG GIẢM GIÁ (NẾU CÓ) ---
                      if (cart.discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        _summaryRow(
                          'Giảm giá:',
                          "-${currencyFormat.format(cart.discountAmount)}",
                          isDiscount: true,
                        ),
                      ],

                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng cộng:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormat.format(cart.totalAfterDiscount),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'TIẾN HÀNH THANH TOÁN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
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

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: isDiscount ? Colors.green : Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDiscount ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    CartViewModel cart,
    String cartId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa sản phẩm"),
        content: const Text("Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cart.removeItem(cartId);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
