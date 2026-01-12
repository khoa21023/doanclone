import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/services/mock_data.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/wishlist_provider.dart';
import '../../cart/cart_screen.dart';

import 'product_detail_screen.dart';
import 'wishlist_screen.dart';
import 'custom_design_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../order/views/order_history_screen.dart';
import '../../../auth/views/login_screen.dart';

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
  String _searchQuery = "";
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

  final List<Product> _allProducts = MockData.products;

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedCaseBrand = null;
    });
  }

  void _onCaseBrandSelected(String brand) {
    setState(() {
      if (_selectedCaseBrand == brand) {
        _selectedCaseBrand = null;
      } else {
        _selectedCaseBrand = brand;
      }
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    double screenWidth = MediaQuery.of(context).size.width;
    // Điều chỉnh số cột linh hoạt để tránh tràn layout grid
    int crossAxisCount = screenWidth > 800 ? 4 : 2;

    // --- LOGIC LỌC SẢN PHẨM ---
    List<Product> displayedProducts = _allProducts.where((p) {
      bool matchesCategory = true;
      if (_selectedCategory == "Tất cả") {
        matchesCategory = true;
      } else {
        matchesCategory = p.type == _selectedCategory;
      }
      if (_selectedCategory == "Ốp lưng" && _selectedCaseBrand != null) {
        matchesCategory = matchesCategory && (p.brand == _selectedCaseBrand);
      }
      final matchesSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();

    // --- LOGIC SẮP XẾP ---
    if (_currentSortOption == 'Tên') {
      displayedProducts.sort((a, b) => a.name.compareTo(b.name));
    } else if (_currentSortOption == 'Giá: Thấp đến Cao') {
      displayedProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_currentSortOption == 'Giá: Cao đến Thấp') {
      displayedProducts.sort((a, b) => b.price.compareTo(a.price));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        elevation: 0,
        // Tăng chiều cao AppBar lên 140 để chứa đủ 2 dòng (Logo/Icon và Search) thoải mái
        toolbarHeight: 140,
        titleSpacing: 0,
        automaticallyImplyLeading: false,

        // --- BỐ CỤC CHÍNH APPBAR ---
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // HÀNG 1: LOGO (Trái) + ICONS (Phải)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. LOGO
                  Flexible( 
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 200, 
                        maxHeight: 60,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/app_logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 2. CÁC BUTTON CHỨC NĂNG
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút Wishlist
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen())), 
                            icon: const Icon(Icons.favorite_border, color: Colors.white, size: 26), 
                            tooltip: 'Yêu thích'
                          ),
                          if (wishlistProvider.items.isNotEmpty)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${wishlistProvider.items.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Nút Giỏ hàng
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            onPressed: _navigateToCart,
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          if (cartProvider.items.isNotEmpty)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${cartProvider.items.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Nút Lịch sử
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderHistoryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 26,
                        ),
                        tooltip: 'Lịch sử',
                      ),

                      // Nút Profile (Hồ sơ)
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),

                      // Nút Logout (Đăng xuất)
                      IconButton(
                        onPressed: () {
                          // Hiển thị hộp thoại xác nhận đăng xuất
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Đăng xuất"),
                                content: const Text(
                                  "Bạn có chắc chắn muốn đăng xuất không?",
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Hủy"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: const Text(
                                      "Đồng ý",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      // Đóng dialog
                                      Navigator.of(context).pop();

                                      // Quay về màn hình Login và xóa hết các màn hình trước đó khỏi stack
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12), 

              // HÀNG 2: THANH TÌM KIẾM
              Container(
                height: 44, 
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: Colors.grey, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        style: const TextStyle(fontSize: 15),
                        textAlignVertical: TextAlignVertical.center, 
                        decoration: const InputDecoration(
                          hintText: 'Bạn tìm gì hôm nay?',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero 
                        ),
                      ),
                    ),
                    // Nút Filter
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        icon: const Icon(
                          Icons.tune,
                          size: 20,
                          color: Color(0xFF0066FF),
                        ),
                        onPressed: () => setState(
                          () => _isFilterVisible = !_isFilterVisible,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BỘ LỌC SẮP XẾP ---
            if (_isFilterVisible)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                              (String value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _currentSortOption = val!),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // --- LIST DANH MỤC ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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

            // --- SUB-CATEGORY ỐP LƯNG & NÚT TỰ THIẾT KẾ ---
            if (_selectedCategory == "Ốp lưng") ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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

                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomDesignScreen(),
                          ),
                        ).then((_) => setState(() {})),
                        icon: const Icon(Icons.brush, size: 16),
                        label: const Text(
                          "Tự thiết kế",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Tìm thấy ${displayedProducts.length} sản phẩm",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),

            // --- GRID SẢN PHẨM ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: displayedProducts.length,
                itemBuilder: (context, index) {
                  final product = displayedProducts[index];
                  final double oldPrice = product.price * 1.15;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => Container(
                                      color: Colors.grey[100],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Tag giảm giá
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
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "-15%",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // ĐÃ XÓA: Nút Wishlist ở góc trên bên phải
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0), // Padding nhỏ lại một chút
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.type, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                
                                // --- LAYOUT MỚI: GIÁ BÊN TRÁI - NÚT "THÊM" BÊN PHẢI ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end, // Căn đáy
                                  children: [
                                    // Cột hiển thị giá
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(currencyFormat.format(product.price), style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text(currencyFormat.format(oldPrice), style: const TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.lineThrough)),
                                        ],
                                      ),
                                    ),
                                    
                                    // Nút "Thêm"
                                    InkWell(
                                      onTap: () {
                                        cartProvider.addItem(product);
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Đã thêm ${product.name} vào giỏ hàng"),
                                            duration: const Duration(seconds: 1),
                                          )
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0066FF), // Màu xanh chủ đạo
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "Thêm",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
          color: isSelected ? const Color(0xFF0066FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0066FF) : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
