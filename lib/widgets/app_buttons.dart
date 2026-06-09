import 'package:clima_track/core/app_colors.dart';
import 'package:clima_track/core/app_textstyles.dart';
import 'package:flutter/material.dart';

class AppButtons {
  // Estilo base
  static ButtonStyle _baseStyle({required Color bg, required Color fg}) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,

      // ⭐ NUEVO: sombra suave industrial (CLM-AESTHETIC)
      elevation: 3,
      shadowColor: AppColors.shadow,

      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

      // ⭐ NUEVO: borde más redondeado (CLM-AESTHETIC)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Estilo base contorno
  static ButtonStyle _outlinedStyle({
    required Color border,
    required Color fg,
  }) {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: border, width: 2),
      foregroundColor: fg,
      backgroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

      // ⭐ NUEVO: borde más redondeado (CLM-AESTHETIC)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Botones azules
  static Widget primary({
    required String text,
    VoidCallback? onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: AppColors.primary, fg: AppColors.white).copyWith(
          // ⭐ NUEVO: borde azul oscuro (CLM-AESTHETIC)
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.primaryDark, width: 1.4),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          // ⭐ NUEVO: tipografía más fuerte (CLM-AESTHETIC)
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget primaryDelete({
    required String text,
    VoidCallback? onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: AppColors.error, fg: AppColors.white).copyWith(
          // ⭐ NUEVO: borde rojo (CLM-AESTHETIC)
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.error, width: 1.4),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget primaryDark({
    required String text,
    required VoidCallback onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: AppColors.primaryDark, fg: AppColors.white)
            .copyWith(
              // ⭐ NUEVO: borde azul (CLM-AESTHETIC)
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primary, width: 1.4),
                ),
              ),
            ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget primaryLight({
    required String text,
    required VoidCallback onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: AppColors.primaryLight, fg: AppColors.white)
            .copyWith(
              // ⭐ NUEVO: borde azul (CLM-AESTHETIC)
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primary, width: 1.4),
                ),
              ),
            ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget outlinedPrimary({
    required String text,
    required VoidCallback onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        style: _outlinedStyle(border: AppColors.primary, fg: AppColors.primary),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Botones naranjas
  static Widget secondary({
    required String text,
    required VoidCallback onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: AppColors.secondary, fg: AppColors.white)
            .copyWith(
              // ⭐ NUEVO: borde naranja oscuro (CLM-AESTHETIC)
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppColors.secondaryDark,
                    width: 1.4,
                  ),
                ),
              ),
            ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget secondaryDark({
    required String text,
    required VoidCallback onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: AppColors.secondaryDark, fg: AppColors.white)
            .copyWith(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppColors.secondary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget secondaryLight({
    required String text,
    required VoidCallback onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: AppColors.secondaryLight, fg: AppColors.white)
            .copyWith(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppColors.secondary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget outlinedSecondary({
    required String text,
    required VoidCallback onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        style: _outlinedStyle(
          border: AppColors.secondary,
          fg: AppColors.secondary,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Botón gris: deshabilitado
  static Widget grey({
    required String text,
    VoidCallback? onPressed,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: AppColors.greyLight, fg: AppColors.black),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w600, // ⭐ NUEVO (CLM-AESTHETIC)
          ),
        ),
      ),
    );
  }

  // Botones con icono
  static Widget withIconPrimary({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    double? width,
    Color backgroundColor = AppColors.primary,
    Color textColor = AppColors.white,
    Color iconColor = AppColors.white,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: backgroundColor, fg: textColor).copyWith(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.primaryDark, width: 1.4),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.body1.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600, // ⭐ NUEVO (CLM-AESTHETIC)
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget withIconSecondary({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    double? width,
    Color backgroundColor = AppColors.secondary,
    Color textColor = AppColors.white,
    Color iconColor = AppColors.white,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: _baseStyle(bg: backgroundColor, fg: textColor).copyWith(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: AppColors.secondaryDark,
                width: 1.4,
              ),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.body1.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600, // ⭐ NUEVO (CLM-AESTHETIC)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
