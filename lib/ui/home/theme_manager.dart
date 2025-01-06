import 'package:flutter/material.dart';
class ThemeManager {
  // Sử dụng ValueNotifier để lưu trạng thái chế độ tối
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static void toggleTheme(bool value) {
    isDarkMode.value = value; // Cập nhật trạng thái
  }
}