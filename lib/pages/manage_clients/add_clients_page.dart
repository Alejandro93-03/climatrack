import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';
import '../manage_clients/edit_installation_page.dart';

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  List<Map<String, dynamic>> installations = [];

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
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
      await FirebaseFirestore.instance.collection('clients').add({
        "name": nameController.text.trim(),
        "address": addressController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "installations": installations,
        "created_at": Timestamp.now(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => errorMessage = "Error al guardar el cliente");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _openAddInstallationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditInstallationPage(
          clientId: "new", 
          installation: null,
          returnMode: true, // modo especial para AddClientPage
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() => installations.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Añadir cliente", style: AppTextStyles.h2w),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppInputs.primary(
              placeholder: "Nombre completo",
              controller: nameController,
              width: double.infinity,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Dirección completa",
              controller: addressController,
              width: double.infinity,
              prefixIcon: Icons.home,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Teléfono",
              controller: phoneController,
              width: double.infinity,
              prefixIcon: Icons.phone,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Email",
              controller: emailController,
              width: double.infinity,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 30),

            // Botón añadir instalación
            AppButtons.secondary(
              text: "Añadir instalación",
              width: double.infinity,
              onPressed: _openAddInstallationPage,
            ),

            const SizedBox(height: 20),

            // Lista de instalaciones añadidas
            if (installations.isNotEmpty)
              Column(
                children: installations.map((inst) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text("${inst['type']} - ${inst['brand']}"),
                      subtitle: Text("Modelo: ${inst['model']}"),
                    ),
                  );
                }).toList(),
              ),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  errorMessage!,
                  style: AppTextStyles.error.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            AppButtons.primary(
              text: isLoading ? "Guardando..." : "Guardar cliente",
              width: double.infinity,
              onPressed: isLoading ? null : _saveClient,
            ),
          ],
        ),
      ),
    );
  }
}
