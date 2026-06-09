import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';

class EditClientPage extends StatefulWidget {
  final String clientId;
  final Map<String, dynamic> initialData;

  const EditClientPage({
    super.key,
    required this.clientId,
    required this.initialData,
  });

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialData["name"]);
    addressController = TextEditingController(
      text: widget.initialData["address"],
    );
    phoneController = TextEditingController(text: widget.initialData["phone"]);
    emailController = TextEditingController(text: widget.initialData["email"]);
  }

  Future<void> _saveChanges() async {
    setState(() => errorMessage = null);

    if (nameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      setState(() => errorMessage = "Todos los campos son obligatorios");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(widget.clientId)
          .update({
            "name": nameController.text.trim(),
            "address": addressController.text.trim(),
            "phone": phoneController.text.trim(),
            "email": emailController.text.trim(),
          });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => errorMessage = "Error al guardar los cambios");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Editar cliente", style: AppTextStyles.h2w),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppInputs.primary(
              placeholder: "Nombre completo*",
              controller: nameController,
              width: double.infinity,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Dirección completa*",
              controller: addressController,
              width: double.infinity,
              prefixIcon: Icons.home,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Teléfono*",
              controller: phoneController,
              width: double.infinity,
              prefixIcon: Icons.phone,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Email*",
              controller: emailController,
              width: double.infinity,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 20),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: AppTextStyles.error.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 30),

            AppButtons.primary(
              text: isLoading ? "Guardando..." : "Guardar cambios",
              width: double.infinity,
              onPressed: isLoading ? null : _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
