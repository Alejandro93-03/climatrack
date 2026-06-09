import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, bool> fieldErrors = {"email": false, "password": false};

  String _firebaseErrorToMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El email no es válido';
      case 'user-not-found':
        return 'No existe ninguna cuenta con este email';
      case 'wrong-password':
      case 'invalid-credential':
        return 'La contraseña es incorrecta';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde';
      case 'network-request-failed':
        return 'Error de conexión. Revisa tu internet';
      default:
        return 'Ha ocurrido un error inesperado';
    }
  }

  Future<void> _performLogin() async {
    setState(() {
      fieldErrors["email"] = false;
      fieldErrors["password"] = false;
      _errorMessage = null;
    });

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        fieldErrors["email"] = _emailController.text.trim().isEmpty;
        fieldErrors["password"] = _passwordController.text.trim().isEmpty;
        _errorMessage = "Todos los campos son obligatorios";
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      final msg = _firebaseErrorToMessage(e.code);

      setState(() {
        _errorMessage = msg;

        if (e.code == "invalid-email" || e.code == "user-not-found") {
          fieldErrors["email"] = true;
        }

        if (e.code == "wrong-password" || e.code == "invalid-credential") {
          fieldErrors["password"] = true;
        }

        if (e.code == "unknown") {
          fieldErrors["email"] = true;
          fieldErrors["password"] = true;
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _login() => _performLogin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.secondaryLight, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Bienvenido',
                  style: AppTextStyles.body2w.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                Transform.scale(
                  scale: 1.7,
                  child: Image.asset('lib/core/images/logo.png', height: 110),
                ),
                const SizedBox(height: 16),

                Text('ClimaTrack', style: AppTextStyles.titleh1w),
                const SizedBox(height: 6),

                Text(
                  'Mantenimiento e instalación de elementos de climatización',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2w,
                ),

                const SizedBox(height: 40),

                AppInputs.primary(
                  placeholder: "Email",
                  controller: _emailController,
                  width: double.infinity,
                  prefixIcon: Icons.email,
                  hasError: fieldErrors["email"]!,
                ),
                const SizedBox(height: 16),

                AppInputs.primaryPassword(
                  placeholder: "Contraseña",
                  controller: _passwordController,
                  obscureText: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                  width: double.infinity,
                  prefixIcon: Icons.lock,
                  hasError: fieldErrors["password"]!,
                ),

                const SizedBox(height: 8),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: AppTextStyles.error.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 24),

                AppButtons.primary(
                  text: _isLoading ? "Cargando..." : "Iniciar sesión",
                  width: double.infinity,
                  onPressed: _isLoading ? null : _login,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
