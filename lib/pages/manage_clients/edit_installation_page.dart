import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';

class EditInstallationPage extends StatefulWidget {
  final String clientId;
  final Map<String, dynamic>? installation;

  /// 🔥 NUEVO: si es true, no guarda en Firestore y devuelve la instalación
  final bool returnMode;

  const EditInstallationPage({
    super.key,
    required this.clientId,
    required this.installation,
    this.returnMode = false,
  });

  @override
  State<EditInstallationPage> createState() => _EditInstallationPageState();
}

class _EditInstallationPageState extends State<EditInstallationPage> {
  final typeController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();

  final installDateController = TextEditingController();
  final lastServiceController = TextEditingController();
  final warrantyController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.installation != null) {
      typeController.text = widget.installation!["type"] ?? "";
      brandController.text = widget.installation!["brand"] ?? "";
      modelController.text = widget.installation!["model"] ?? "";
      installDateController.text = widget.installation!["install_date"] ?? "";
      lastServiceController.text =
          widget.installation!["last_service_date"] ?? "";
      warrantyController.text = widget.installation!["warranty_expiry"] ?? "";
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      useRootNavigator: true, // 🔥 FUNCIONA SIEMPRE, incluso dentro de diálogos
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      helpText: "Selecciona una fecha",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _saveInstallation() async {
    final newInstallation = {
      "type": typeController.text.trim(),
      "brand": brandController.text.trim(),
      "model": modelController.text.trim(),
      "install_date": installDateController.text.trim(),
      "last_service_date": lastServiceController.text.trim(),
      "warranty_expiry": warrantyController.text.trim(),
    };

    // 🔥 MODO RETURN → vuelve a AddClientPage sin guardar en Firestore
    if (widget.returnMode) {
      Navigator.pop(context, newInstallation);
      return;
    }

    // 🔥 MODO NORMAL → guarda en Firestore
    setState(() => isLoading = true);

    final doc = FirebaseFirestore.instance
        .collection('clients')
        .doc(widget.clientId);

    final snap = await doc.get();
    final data = snap.data() as Map<String, dynamic>;

    final List installations = List.from(data["installations"] ?? []);

    if (widget.installation != null) {
      final index = installations.indexOf(widget.installation);
      if (index != -1) installations[index] = newInstallation;
    } else {
      installations.add(newInstallation);
    }

    await doc.update({"installations": installations});

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.installation != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditing ? "Editar instalación" : "Añadir instalación",
          style: AppTextStyles.h2w,
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppInputs.primary(
              placeholder: "Tipo",
              controller: typeController,
              width: double.infinity,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Marca",
              controller: brandController,
              width: double.infinity,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Modelo",
              controller: modelController,
              width: double.infinity,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Fecha instalación",
              controller: installDateController,
              readOnly: true,
              prefixIcon: Icons.calendar_today,
              onTap: () => _pickDate(installDateController),
              width: double.infinity,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Último servicio",
              controller: lastServiceController,
              readOnly: true,
              prefixIcon: Icons.calendar_today,
              onTap: () => _pickDate(lastServiceController),
              width: double.infinity,
            ),
            const SizedBox(height: 20),

            AppInputs.primary(
              placeholder: "Fin garantía",
              controller: warrantyController,
              readOnly: true,
              prefixIcon: Icons.calendar_today,
              onTap: () => _pickDate(warrantyController),
              width: double.infinity,
            ),
            const SizedBox(height: 30),

            AppButtons.primary(
              text: isLoading ? "Guardando..." : "Guardar",
              width: double.infinity,
              onPressed: isLoading ? null : _saveInstallation,
            ),
          ],
        ),
      ),
    );
  }
}
