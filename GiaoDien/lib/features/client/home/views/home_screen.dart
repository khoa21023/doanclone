import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/product_model.dart';
import '../../product/view_models/product_view_model.dart';
import '../../../../data/providers/home_cart_provider.dart';
import '../../../../data/providers/wishlist_provider.dart';

import '../../cart/views/cart_screen.dart';
import '../../product/views/product_detail_screen.dart';
import '../../wishlist/views/wishlist_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../order/views/order_history_screen.dart';
import '../../../auth/views/login_screen.dart';
import '../../cart/view_models/cart_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isFilterVisible = false;
  String _selectedCategory = "Tất cả";
  String _currentSortOption = "Tên";
  String? _selectedCaseBrand;

  final List<String> _categories = [
    "Tất cả",
    "Màn hình",
    "Pin",
    "Camera",
    "Cổng sạc",
    "Loa",
    "Ốp lưng",
    "Motor",
    "Nút",
    "Phụ kiện",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    String? keyword = _searchController.text;
    if (_selectedCategory == "Ốp lưng" && _selectedCaseBrand != null) {
      keyword = "$keyword $_selectedCaseBrand".trim();
    }

    context.read<ClientProductViewModel>().fetchProducts(
      category: _selectedCategory,
      sortOption: _currentSortOption,
      keyword: keyword,
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedCaseBrand = null;
    });
    _fetchData();
  }

  void _onCaseBrandSelected(String brand) {
    setState(() {
      _selectedCaseBrand = (_selectedCaseBrand == brand) ? null : brand;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final cartViewModel = Provider.of<CartViewModel>(context);
    // ignore: unused_local_variable
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 800 ? 4 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 10, // Giảm khoảng cách để tiết kiệm diện tích
        title: Row(
          children: [
            // Logo
            Image.asset(
              'assets/images/app_logo.jpg',
              height: 40,
              width: 60,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.store, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 8),
            // Tên App
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Mobile Tech",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Linh kiện chính hãng",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 1. Nút Lịch sử đơn hàng
          IconButton(
            tooltip: "Lịch sử đơn hàng",
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
          ),

          // 2. Nút Yêu thích (Wishlist)
          IconButton(
            tooltip: "Sản phẩm yêu thích",
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),

          // 3. Nút Giỏ hàng (Có Badge số lượng)
          Consumer<CartViewModel>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
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
              );
            },
          ),

          // 4. Menu phụ (Tài khoản, Đăng xuất)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text("Tài khoản"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // === PHẦN TÌM KIẾM (Đưa xuống body để rộng rãi hơn) ===
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: const BoxDecoration(
              color: Color(
                0xFF2563EB,
              ), // Cùng màu với AppBar tạo cảm giác liền mạch
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) =>
                    context.read<ClientProductViewModel>().onSearchChanged(
                      val,
                      _selectedCategory,
                      _currentSortOption,
                    ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Bạn tìm linh kiện gì hôm nay?',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _isFilterVisible
                          ? const Color(0xFF2563EB)
                          : Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _isFilterVisible = !_isFilterVisible),
                  ),
                ),
              ),
            ),
          ),

          // 1. THANH LỌC SẮP XẾP (Hiện ra khi bấm icon Tune)
          if (_isFilterVisible)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    "Sắp xếp: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _currentSortOption,
                      underline: Container(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                      items: ['Tên', 'Giá: Thấp đến Cao', 'Giá: Cao đến Thấp']
                          .map(
                            (val) =>
                                DropdownMenuItem(value: val, child: Text(val)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _currentSortOption = val);
                          _fetchData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

          // 2. DANH SÁCH DANH MỤC (Categories)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _categories
                        .map(
                          (c) => _buildCategoryChip(
                            c,
                            isSelected: c == _selectedCategory,
                          ),
                        )
                        .toList(),
                  ),
                ),

                if (_selectedCategory == "Ốp lưng") ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildSubCategoryChip(
                          "iPhone",
                          isSelected: _selectedCaseBrand == "iPhone",
                        ),
                        _buildSubCategoryChip(
                          "Samsung",
                          isSelected: _selectedCaseBrand == "Samsung",
                        ),
                        _buildSubCategoryChip(
                          "Xiaomi",
                          isSelected: _selectedCaseBrand == "Xiaomi",
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 3. DANH SÁCH SẢN PHẨM
          Expanded(
            child: Consumer<ClientProductViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 10),
                        Text(viewModel.errorMessage!),
                        TextButton(
                          onPressed: _fetchData,
                          child: const Text("Thử lại"),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.products.isEmpty) {
                  return const Center(
                    child: Text("Không tìm thấy sản phẩm nào"),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _fetchData(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: viewModel.products.length,
                    itemBuilder: (context, index) {
                      final product = viewModel.products[index];
                      final double oldPrice = product.sellPrice * 1.1;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ảnh sản phẩm
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Center(
                                        child: Image.network(
                                          product.imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          "-10%",
                                          style: TextStyle(
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
                              // Thông tin
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormat.format(product.sellPrice),
                                      style: const TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      currencyFormat.format(oldPrice),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Nút thêm nhanh
                                    SizedBox(
                                      width: double.infinity,
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2563EB,
                                          ),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          bool success = await context
                                              .read<CartViewModel>()
                                              .addToCart(product.id, 1);
                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Đã thêm ${product.name}",
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 800,
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          "Thêm vào giỏ",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _onCategorySelected(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryChip(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _onCaseBrandSelected(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2563EB) : Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có muốn đăng xuất?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
