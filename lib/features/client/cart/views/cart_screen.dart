import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../data/providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Giỏ hàng (${cart.items.length})'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text(
                    'Giỏ hàng rỗng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Nhấn nút bên dưới để thêm sản phẩm!', style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Mua hàng ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- HIỂN THỊ ẢNH SẢN PHẨM ---
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100], 
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300)
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.isCustomDesign && item.customImage != null
                                      // 1. Nếu là hàng custom -> Hiện ảnh từ Memory (ảnh chụp màn hình thiết kế)
                                      ? Image.memory(
                                          item.customImage!,
                                          fit: BoxFit.contain,
                                        )
                                      // 2. Nếu là hàng thường -> Hiện ảnh từ Network
                                      : Image.network(
                                          item.product.imageUrl, 
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                  ),
                                ),
                                // -----------------------------
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Hiển thị chi tiết (nếu là custom)
                                      if (item.isCustomDesign)
                                        Text(
                                          "Thiết kế riêng ${item.customText != null ? '+ Chữ' : ''} ${item.sticker != null ? '+ Sticker' : ''}",
                                          style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),
                                        )
                                      else
                                        Text(
                                          item.product.type == 'phone' ? 'Điện thoại' : 'Phụ kiện',
                                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                        ),
                                      
                                      const SizedBox(height: 8),
                                      Text(
                                        currencyFormat.format(item.product.price),
                                        style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildQuantityButton(Icons.remove, () => cart.decreaseItem(item.product.id)),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 40,
                                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    _buildQuantityButton(Icons.add, () => cart.addItem(item.product)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      currencyFormat.format(item.product.price * item.quantity),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      onPressed: () => cart.removeItem(item.product.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tạm tính', style: TextStyle(color: Colors.grey[600])),
                          Text(currencyFormat.format(cart.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Phí giao hàng', style: TextStyle(color: Colors.grey[600])),
                          Text(currencyFormat.format(30000), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Thành tiền', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormat.format(cart.totalAmount + 30000),
                            style: const TextStyle(fontSize: 20, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text('Tiến hành thanh toán', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[600]),
      ),
    );
  }
}