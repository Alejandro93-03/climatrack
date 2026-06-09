import 'package:clima_track/core/app_colors.dart';
import 'package:clima_track/core/app_textstyles.dart';
import 'package:flutter/material.dart';

class AppInputs {
  // -------------------------------------------------------------
  // BASE DECORATION
  // -------------------------------------------------------------
  static InputDecoration _baseDecoration({
    required String placeholder,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.greyDark),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      border: InputBorder.none,
    );
  }

  // -------------------------------------------------------------
  // WRAPPER GENERAL
  // -------------------------------------------------------------
  static Widget _inputWrapper({
    required bool isFocused,
    required bool hasError,
    required Color borderColor,
    required Color focusedBorderColor,
    required Widget textField,
    double? width,
  }) {
    final Color finalBorderColor = hasError
        ? AppColors.error
        : (isFocused ? focusedBorderColor : borderColor);

    final double finalBorderWidth = hasError ? 2 : (isFocused ? 2 : 1.5);

    return SizedBox(
      width: width,
      child: Stack(
        children: [
          if (!isFocused && !hasError)
            Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: borderColor.withOpacity(0.15))],
              ),
            ),

          if (isFocused && !hasError)
            Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: focusedBorderColor.withOpacity(0.25),
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
            ),

          Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: finalBorderColor,
                width: finalBorderWidth,
              ),
            ),
            child: textField,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PRIMARY INPUT (actualizado con readOnly + onTap)
  // -------------------------------------------------------------
  static Widget primary({
    required String placeholder,
    double? width,
    TextEditingController? controller,
    FocusNode? focusNode,
    IconData? prefixIcon,
    bool hasError = false,
    bool readOnly = false, // 👈 NUEVO
    VoidCallback? onTap, // 👈 NUEVO
    TextInputType? keyboardType,
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    final Color iconColor = hasError
        ? AppColors.error
        : (isFocused ? AppColors.primaryDark : AppColors.greyDark);

    return _inputWrapper(
      width: width,
      isFocused: isFocused,
      hasError: hasError,
      borderColor: AppColors.primary,
      focusedBorderColor: AppColors.primaryDark,
      textField: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly, // 👈 AÑADIDO
        onTap: onTap, // 👈 AÑADIDO
        keyboardType: keyboardType,
        decoration: _baseDecoration(
          placeholder: placeholder,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: iconColor)
              : null,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // SECONDARY INPUT
  // -------------------------------------------------------------
  static Widget secondary({
    required String placeholder,
    double? width,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool hasError = false,
    bool readOnly = false, // 👈 NUEVO
    VoidCallback? onTap, // 👈 NUEVO
    TextInputType? keyboardType,
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    return _inputWrapper(
      width: width,
      isFocused: isFocused,
      hasError: hasError,
      borderColor: AppColors.secondary,
      focusedBorderColor: AppColors.secondaryDark,
      textField: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly, // 👈 AÑADIDO
        onTap: onTap, // 👈 AÑADIDO
        keyboardType: keyboardType,
        decoration: _baseDecoration(placeholder: placeholder),
      ),
    );
  }

  // -------------------------------------------------------------
  // PRIMARY PASSWORD
  // -------------------------------------------------------------
  static Widget primaryPassword({
    required String placeholder,
    double? width,
    required bool obscureText,
    required VoidCallback onToggle,
    FocusNode? focusNode,
    TextEditingController? controller,
    IconData? prefixIcon,
    bool hasError = false,
    bool readOnly = false, // 👈 NUEVO
    VoidCallback? onTap, // 👈 NUEVO
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    final Color iconColor = hasError
        ? AppColors.error
        : (isFocused ? AppColors.primaryDark : AppColors.greyDark);

    return _inputWrapper(
      width: width,
      isFocused: isFocused,
      hasError: hasError,
      borderColor: AppColors.primary,
      focusedBorderColor: AppColors.primaryDark,
      textField: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        readOnly: readOnly, // 👈 AÑADIDO
        onTap: onTap, // 👈 AÑADIDO
        decoration: _baseDecoration(
          placeholder: placeholder,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: iconColor)
              : null,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: iconColor,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PRIMARY WITH SEARCH
  // -------------------------------------------------------------
  static Widget primaryWithSearch({
    required String placeholder,
    double? width,
    FocusNode? focusNode,
    TextEditingController? controller,
    bool hasError = false,
    bool readOnly = false, // 👈 NUEVO
    VoidCallback? onTap, // 👈 NUEVO
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    final Color iconColor = hasError
        ? AppColors.error
        : (isFocused ? AppColors.primaryDark : AppColors.greyDark);

    return _inputWrapper(
      width: width,
      isFocused: isFocused,
      hasError: hasError,
      borderColor: AppColors.primary,
      focusedBorderColor: AppColors.primaryDark,
      textField: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly, // 👈 AÑADIDO
        onTap: onTap, // 👈 AÑADIDO
        decoration: _baseDecoration(
          placeholder: placeholder,
          suffixIcon: Icon(Icons.search, color: iconColor),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // ACCENT WITH SEARCH
  // -------------------------------------------------------------
  static Widget accentWithSearch({
    required String placeholder,
    double? width,
    FocusNode? focusNode,
    TextEditingController? controller,
    bool hasError = false,
    bool readOnly = false, // 👈 NUEVO
    VoidCallback? onTap, // 👈 NUEVO
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    final Color iconColor = hasError
        ? AppColors.error
        : (isFocused ? AppColors.secondaryDark : AppColors.greyDark);

    return _inputWrapper(
      width: width,
      isFocused: isFocused,
      hasError: hasError,
      borderColor: AppColors.secondary,
      focusedBorderColor: AppColors.secondaryDark,
      textField: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly, // 👈 AÑADIDO
        onTap: onTap, // 👈 AÑADIDO
        decoration: _baseDecoration(
          placeholder: placeholder,
          suffixIcon: Icon(Icons.search, color: iconColor),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PRIMARY MULTILINE
  // -------------------------------------------------------------
  static Widget primaryMultiline({
    required String placeholder,
    required TextEditingController controller,
    required double width,
    int maxLines = 5,
    FormFieldValidator<String>? validator,
    FocusNode? focusNode,
    bool hasError = false,
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    final Color borderColor = hasError ? AppColors.error : AppColors.primary;
    final Color focusedBorderColor = hasError
        ? AppColors.error
        : AppColors.primaryDark;

    return SizedBox(
      width: width,
      child: Stack(
        children: [
          if (!isFocused && !hasError)
            Container(
              height: maxLines * 24 + 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.15)),
                ],
              ),
            ),

          if (isFocused && !hasError)
            Container(
              height: maxLines * 24 + 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.25),
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
            ),

          Container(
            height: maxLines * 24 + 28,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFocused ? focusedBorderColor : borderColor,
                width: isFocused ? 2 : 1.5,
              ),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              maxLines: maxLines,
              validator: validator,
              style: AppTextStyles.body1.copyWith(color: AppColors.black),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.greyDark,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
