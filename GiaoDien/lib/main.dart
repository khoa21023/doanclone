import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/home_cart_provider.dart';
import 'data/providers/wishlist_provider.dart';
import 'features/auth/view_models/login_view_model.dart';
import 'features/auth/view_models/signup_view_model.dart';
import 'features/auth/views/login_screen.dart';
import 'features/admin/promotions/view_models/promotions_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

        // --- THÊM DÒNG NÀY ĐỂ SỬA LỖI MÀN HÌNH ĐỎ ---
        ChangeNotifierProvider(create: (_) => PromotionsViewModel()),

        // GỢI Ý: Nếu bạn có ProductViewModel hay OrderViewModel dùng cho Dashboard
        // thì cũng nên thêm luôn vào đây để tránh lỗi tương tự ở các tab khác:
        // ChangeNotifierProvider(create: (_) => ProductViewModel()),
        // ChangeNotifierProvider(create: (_) => OrderViewModel()),
      ],
      child: MaterialApp(
        title: 'Mobile Tech CT',
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
