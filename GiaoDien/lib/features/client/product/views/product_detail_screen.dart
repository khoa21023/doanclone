import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/providers/home_cart_provider.dart';
import '../../cart/views/cart_screen.dart';
import '../view_models/client_product_detail_view_model.dart';
import '../../cart/view_models/cart_view_model.dart';
import '../../wishlist/view_models/wishlist_view_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ClientProductDetailViewModel()..fetchProductDetail(widget.product.id),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Chi tiết sản phẩm",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          actions: [
            Consumer<CartProvider>(
              builder: (context, cart, child) => Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  if (cart.items.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        body: Consumer<ClientProductDetailViewModel>(
          builder: (context, viewModel, child) {
            // Ưu tiên dữ liệu từ API, nếu chưa có thì dùng dữ liệu truyền vào
            final displayProduct = viewModel.product ?? widget.product;

            final currencyFormat = NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'đ',
              decimalDigits: 0,
            );
            final double oldPrice = displayProduct.sellPrice * 1.1; // Giá ảo

            // --- GIẢ LẬP CÁC TRƯỜNG THIẾU (FIX LỖI) ---
            // Vì Model thật chưa có các cột này, ta gán cứng để App không lỗi
            final String productType =
                "Linh kiện chính hãng"; // Thay cho displayProduct.type
            final double rating = 5.0; // Thay cho displayProduct.rating
            final int reviews = 99; // Thay cho displayProduct.reviews
            final String condition =
                "Mới 100%"; // Thay cho displayProduct.condition
            final String color = "Tiêu chuẩn"; // Thay cho displayProduct.color

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. ẢNH SẢN PHẨM
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 300,
                              color: Colors.grey.shade50,
                              child: Image.network(
                                displayProduct.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Hot Sale",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 2. THÔNG TIN CHI TIẾT
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Loại sản phẩm (Đã sửa lỗi)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  productType,
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Tên sản phẩm
                              Text(
                                displayProduct.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Đánh giá (Đã sửa lỗi)
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star, // Mặc định 5 sao
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "$rating ($reviews đánh giá)",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Giá bán
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(
                                      displayProduct.sellPrice,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    currencyFormat.format(oldPrice),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Mô tả
                              const Text(
                                "Mô tả sản phẩm",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                // Nếu description null thì hiện text mặc định
                                (displayProduct.description.isNotEmpty)
                                    ? displayProduct.description
                                    : "Sản phẩm chính hãng chất lượng cao. Tình trạng: $condition. Màu sắc: $color. Bảo hành 12 tháng tại Mobile Tech CT.",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Chọn số lượng
                              const Text(
                                "Số lượng",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildQtyButton(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (quantity > 1)
                                        setState(() => quantity--);
                                    },
                                  ),
                                  Container(
                                    width: 50,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "$quantity",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _buildQtyButton(
                                    icon: Icons.add,
                                    onTap: () {
                                      setState(() => quantity++);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. THANH BOTTOM BAR
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // NÚT YÊU THÍCH
                      Consumer<WishlistViewModel>(
                        builder: (context, wishlist, _) {
                          final isFav = wishlist.isFavorite(displayProduct.id);
                          return GestureDetector(
                            onTap: () {
                              wishlist.toggleFavorite(displayProduct);
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFav
                                        ? "Đã xóa khỏi yêu thích"
                                        : "Đã thêm vào yêu thích",
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav
                                    ? Colors.red
                                    : Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),

                      // NÚT THÊM VÀO GIỎ
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              bool success = await context
                                  .read<CartViewModel>()
                                  .addToCart(displayProduct.id, quantity);
                              if (!context.mounted) return;
                              if (success) {
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Đã thêm $quantity ${displayProduct.name} vào giỏ!",
                                    ),
                                    backgroundColor: Colors.green,
                                    action: SnackBarAction(
                                      label: 'Đến giỏ hàng',
                                      textColor: Colors.white,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const CartScreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lỗi thêm vào giỏ hàng"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Thêm vào giỏ hàng",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
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

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}
