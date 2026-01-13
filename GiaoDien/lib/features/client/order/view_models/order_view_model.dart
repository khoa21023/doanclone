import 'package:flutter/material.dart';
import '../../../../data/models/order.dart';

class OrderStatus {
  static const String daDat = 'Đã đặt';
  static const String dangGiao = 'Đang giao';
  static const String daGiao = 'Đã giao';
  static const String daHuy = 'Đã hủy';
}

class OrderViewModel extends ChangeNotifier {
  final List<Order> _orders = [
    Order(
      id: 'ORD-1767520263962',
      userName: 'Khoa',
      userEmail: 'khoa@gmail.com',
      status: OrderStatus.daDat,
      paymentMethod: 'COD',
      createdAt: DateTime(2026, 4, 1, 16, 51),
      total: 1027.81,
      items: [
        OrderItem(
          productId: '1',
          productName: 'Cáp nguồn cổng sạc iPhone',
          quantity: 7,
          price: 174.93,
        ),
        OrderItem(
          productId: '2',
          productName: 'Bộ ống kính Camera đa năng',
          quantity: 10,
          price: 799.9,
        ),
        OrderItem(
          productId: '3',
          productName: 'Bộ kính cường lực cao cấp',
          quantity: 1,
          price: 12.99,
        ),
        OrderItem(
          productId: '4',
          productName: 'Loa thoại thay thế',
          quantity: 1,
          price: 34.99,
        ),
      ],
    ),
    Order(
      id: 'ORD-1767520263963',
      userName: 'Ngọc',
      userEmail: 'ngoc@gmail.com',
      status: OrderStatus.dangGiao,
      paymentMethod: 'COD',
      createdAt: DateTime(2026, 4, 2, 09, 30),
      total: 1027.81,
      items: [
        OrderItem(
          productId: '1',
          productName: 'Cáp nguồn cổng sạc iPhone',
          quantity: 7,
          price: 174.93,
        ),
        OrderItem(
          productId: '2',
          productName: 'Bộ ống kính Camera đa năng',
          quantity: 10,
          price: 799.9,
        ),
      ],
    ),
    Order(
      id: 'ORD-1767520263965',
      userName: 'Trinh',
      userEmail: 'trinh@gmail.com',
      status: OrderStatus.daGiao,
      paymentMethod: 'Credit Card',
      createdAt: DateTime(2026, 3, 28, 14, 20),
      total: 1250.00,
      items: [
        OrderItem(
          productId: '5',
          productName: 'Tai nghe Bluetooth Pro',
          quantity: 1,
          price: 1250.00,
        ),
      ],
    ),
    Order(
      id: 'ORD-1767520263964',
      userName: 'Duy',
      userEmail: 'duy@gmail.com',
      status: OrderStatus.daHuy,
      paymentMethod: 'COD',
      createdAt: DateTime(2026, 4, 3, 10, 15),
      total: 1027.81,
      items: [
        OrderItem(
          productId: '1',
          productName: 'Cáp nguồn cổng sạc iPhone',
          quantity: 7,
          price: 174.93,
        ),
        OrderItem(
          productId: '2',
          productName: 'Bộ ống kính Camera đa năng',
          quantity: 10,
          price: 799.9,
        ),
      ],
    ),
  ];

  List<Order> get orders => _orders;
}