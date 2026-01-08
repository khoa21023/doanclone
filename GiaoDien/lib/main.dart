import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/wishlist_provider.dart';
import 'features/auth/view_models/login_view_model.dart';
import 'features/auth/view_models/signup_view_model.dart';
import 'features/auth/views/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- DATA PROVIDERS (Dữ liệu dùng chung toàn app) ---
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),

        // --- AUTH PROVIDERS (Nếu muốn dùng chung, hoặc khai báo tại màn hình cũng được) ---
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
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
