import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';

class AddInstallerPage extends StatefulWidget {
  const AddInstallerPage({super.key});

  @override
  State<AddInstallerPage> createState() => _AddInstallerPageState();
}

class _AddInstallerPageState extends State<AddInstallerPage> {
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveInstaller() async {
    setState(() => errorMessage = null);

    if (nameController.text.trim().isEmpty ||
        lastnameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() => errorMessage = "Todos los campos son obligatorios");
      return;
    }

    setState(() => isLoading = true);

    FirebaseApp? tempApp;

    try {
      // Intentar obtener la app temporal si ya existe, o crearla
      try {
        tempApp = Firebase.app('tempApp');
      } catch (_) {
        tempApp = await Firebase.initializeApp(
          name: 'tempApp',
          options: Firebase.app().options,
        );
      }

      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final cred = await tempAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final newUid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(newUid).set({
        "email": emailController.text.trim(),
        "name": nameController.text.trim(),
        "lastname": lastnameController.text.trim(),
        "created_at": FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => errorMessage = "Error al crear el técnico: $e");
    } finally {
      await tempApp?.delete();
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Añadir técnico", style: AppTextStyles.h2w),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppInputs.primary(
              placeholder: "Nombre",
              controller: nameController,
              width: double.infinity,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Apellidos",
              controller: lastnameController,
              width: double.infinity,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Email",
              controller: emailController,
              width: double.infinity,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Contraseña",
              controller: passwordController,
              width: double.infinity,
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 30),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  errorMessage!,
                  style: AppTextStyles.error.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            AppButtons.primary(
              text: isLoading ? "Creando..." : "Crear técnico",
              width: double.infinity,
              onPressed: isLoading ? null : _saveInstaller,
            ),
          ],
        ),
      ),
    );
  }
}
