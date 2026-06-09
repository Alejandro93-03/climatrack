import 'package:flutter/material.dart';

class AppColors {
  // Principales
  static const Color background = Color(0xFFF5F7FA); //Industrial White
  static const Color primary = Color(0xFF005C97); // AC Blue
  static const Color secondary = Color(0xFFF26419); // Gas Orange
  static const Color success = Color(0xFF2ECC71); // Completed

  // Variantes
  static const Color primaryDark = Color(0xFF004A7A);
  static const Color primaryLight = Color(0xFF4A8FBE);
  static const Color secondaryDark = Color(0xFFC94E0F);
  static const Color secondaryLight = Color(0xFFFF9A5C);
  static const Color successDark = Color(0xFF27AE60);
  static const Color successLight = Color(0xFF58D68D);

  // Escala de grises
  static const Color black = Color(0xFF1A1A1A);
  static const Color greyDark = Color(0xFF6B7280);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color greyLight = Color(0xFFE5E7EB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFD5D9DE);
  static const Color shadow = Color(0x11000000);

  // Estados
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = primary;

  // Degradados
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF005C97), Color(0xFF3A7FB0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFF26419), Color(0xFFFF8A4C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
