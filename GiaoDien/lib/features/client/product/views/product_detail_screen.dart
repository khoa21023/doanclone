// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// import '../../../../data/models/product_model.dart';
// import '../../../../data/providers/home_cart_provider.dart';
// import '../../../../data/providers/wishlist_provider.dart';
// import '../../cart/views/cart_screen.dart';

// class ProductDetailScreen extends StatefulWidget {
//   final Product product;
//   const ProductDetailScreen({super.key, required this.product});

//   @override
//   State<ProductDetailScreen> createState() => _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends State<ProductDetailScreen> {
//   int quantity = 1;

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat = NumberFormat.currency(
//       locale: 'vi_VN',
//       symbol: 'VND',
//       decimalDigits: 0,
//     );
//     final double oldPrice = widget.product.price * 1.15;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Chi tiết sản phẩm",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         backgroundColor: const Color(0xFF2563EB),
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const CartScreen()),
//               );
//             },
//             icon: const Icon(Icons.shopping_cart_outlined),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 1. ẢNH SẢN PHẨM
//                   Stack(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         height: 300,
//                         color: Colors.grey.shade50,
//                         child: Image.network(
//                           widget.product.imageUrl,
//                           fit: BoxFit.contain,
//                           errorBuilder: (c, e, s) => const Icon(
//                             Icons.broken_image,
//                             size: 50,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: 16,
//                         left: 16,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Text(
//                             "Giảm 15%",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   // 2. THÔNG TIN
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             widget.product.type,
//                             style: TextStyle(
//                               color: Colors.blue.shade700,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           widget.product.name,
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Row(
//                               children: List.generate(
//                                 5,
//                                 (index) => Icon(
//                                   index < (widget.product.rating).floor()
//                                       ? Icons.star
//                                       : Icons.star_border,
//                                   color: Colors.amber,
//                                   size: 20,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               "${widget.product.rating} (${widget.product.reviews} đánh giá)",
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               currencyFormat.format(widget.product.price),
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF2563EB),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               currencyFormat.format(oldPrice),
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                                 decoration: TextDecoration.lineThrough,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),
//                         const Text(
//                           "Mô tả sản phẩm",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Sản phẩm chính hãng chất lượng cao. Tình trạng: ${widget.product.condition}. Màu sắc: ${widget.product.color}. Bảo hành 12 tháng tại Mobile Tech CT.",
//                           style: TextStyle(
//                             color: Colors.grey.shade700,
//                             height: 1.5,
//                           ),
//                         ),

//                         const SizedBox(height: 24),
//                         const Text(
//                           "Số lượng",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             _buildQtyButton(
//                               icon: Icons.remove,
//                               onTap: () {
//                                 if (quantity > 1) setState(() => quantity--);
//                               },
//                             ),
//                             Container(
//                               width: 50,
//                               alignment: Alignment.center,
//                               child: Text(
//                                 "$quantity",
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             _buildQtyButton(
//                               icon: Icons.add,
//                               onTap: () {
//                                 setState(() => quantity++);
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // 4. THANH BOTTOM BAR
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 // NÚT 1: WISHLIST (Icon trái tim)
//                 Consumer<WishlistProvider>(
//                   builder: (context, wishlist, _) {
//                     final isFav = wishlist.isFavorite(widget.product.id);
//                     return GestureDetector(
//                       onTap: () {
//                         wishlist.toggleFavorite(widget.product);
//                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               isFav
//                                   ? "Đã xóa khỏi yêu thích"
//                                   : "Đã thêm vào yêu thích",
//                             ),
//                             duration: const Duration(seconds: 1),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           isFav ? Icons.favorite : Icons.favorite_border,
//                           color: isFav ? Colors.red : Colors.grey.shade600,
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(width: 16),

//                 // NÚT 2: THÊM VÀO GIỎ HÀNG
//                 Expanded(
//                   child: SizedBox(
//                     height: 50,
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         context.read<CartProvider>().addItem(
//                           widget.product,
//                           quantity: quantity,
//                         );
//                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               "Đã thêm ${quantity} ${widget.product.name} vào giỏ hàng!",
//                             ),
//                             duration: const Duration(seconds: 1),
//                             action: SnackBarAction(
//                               label: 'Đến giỏ hàng',
//                               textColor: Colors.yellow,
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const CartScreen(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                       icon: const Icon(
//                         Icons.add_shopping_cart,
//                         color: Colors.white,
//                       ),
//                       label: const Text(
//                         "Thêm vào giỏ hàng",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2563EB),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         elevation: 0,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQtyButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, size: 18, color: Colors.black87),
//       ),
//     );
//   }
// }
