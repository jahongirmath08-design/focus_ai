import 'package:flutter/material.dart';

/// BARCHA brend va palitra ranglari SHU YERDA (bitta joyda).
/// Eslatma: aksent rang PLACEHOLDER — brending javobi kelganda shu yerdan o'zgartiramiz.
class AppColors {
  AppColors._();

  /// Asosiy aksent (placeholder — strategiya hujjatidan).
  static const Color accent = Color(0xFF6C5CE7);

  /// Odat uchun tanlanadigan ranglar (foydalanuvchi tanlaydi).
  static const List<Color> habitColors = [
    Color(0xFF6C5CE7), // binafsha
    Color(0xFF00D2D3), // siyan
    Color(0xFFFFD86E), // amber
    Color(0xFFFF7675), // marjon
    Color(0xFF55EFC4), // yashil
    Color(0xFFFD79A8), // pushti
    Color(0xFF74B9FF), // moviy
    Color(0xFFFFA94D), // to'q sariq
    Color(0xFFA29BFE), // lavanda
    Color(0xFF63E6BE), // dengiz yashili
    Color(0xFFFF6B6B), // qizil
    Color(0xFFE599F7), // siyohrang
  ];
}
