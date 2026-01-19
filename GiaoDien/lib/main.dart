import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/home_cart_provider.dart';
import 'data/providers/wishlist_provider.dart';
import 'features/auth/view_models/login_view_model.dart';
import 'features/auth/view_models/signup_view_model.dart';
import 'features/auth/views/login_screen.dart';
import 'features/admin/promotions/view_models/promotions_view_model.dart';
import 'features/client/product/view_models/product_view_model.dart';
import 'features/client/cart/view_models/cart_view_model.dart';
import 'package:app_links/app_links.dart';
import 'features/client/checkout/views/success_screen.dart';
import 'features/client/order/view_models/order_view_model.dart';
import 'features/client/wishlist/view_models/wishlist_view_model.dart';
import 'dart:async';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // --- HÀM LẮNG NGHE DEEP LINK ---
  void _initDeepLinkListener() {
    _appLinks = AppLinks();

    // Lắng nghe khi App đang chạy nền hoặc được mở lại từ link
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print("Nhận được Deep Link: $uri");
        _handleDeepLink(uri);
      }
    });
  }

  // Xử lý Logic chuyển trang
  void _handleDeepLink(Uri uri) {
    // Backend trả về: mobiletech://payment/success
    if (uri.scheme == 'mobiletech' && uri.host == 'payment') {
      if (uri.path.contains('success')) {
        // Điều hướng đến màn hình thành công
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SuccessScreen()),
          (route) => false, // Xóa hết lịch sử cũ (Giỏ hàng, Checkout...)
        );
      } else if (uri.path.contains('cancel')) {
        // Điều hướng về trang Giỏ hàng hoặc thông báo lỗi
        print("Người dùng đã hủy thanh toán");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- DATA PROVIDERS ---
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),

        // --- AUTH PROVIDERS ---
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),

        ChangeNotifierProvider(create: (_) => PromotionsViewModel()),

        ChangeNotifierProvider(create: (_) => ClientProductViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
      ],
      child: MaterialApp(
        title: 'Mobile Tech CT',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2563EB),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF0F9FF),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        home: LoginScreen(),
      ),
    );
  }
}
