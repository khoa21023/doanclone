import 'package:flutter/material.dart';

class DesignItem {
  final String id;
  final String type; // 'text' hoặc 'sticker'
  final String content; // Nội dung text hoặc icon string
  final Color? color;   // Màu sắc (chỉ dùng cho text)
  Offset position;      // Vị trí trên màn hình

  DesignItem({
    required this.id,
    required this.type,
    required this.content,
    this.color,
    required this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'color': color?.value, // Lưu mã màu dạng int
      'dx': position.dx,     // Lưu tọa độ X
      'dy': position.dy,     // Lưu tọa độ Y
    };
  }

  factory DesignItem.fromMap(Map<String, dynamic> map) {
    return DesignItem(
      id: map['id'],
      type: map['type'],
      content: map['content'],
      color: map['color'] != null ? Color(map['color']) : null,
      position: Offset(map['dx'] ?? 0.0, map['dy'] ?? 0.0),
    );
  }
}