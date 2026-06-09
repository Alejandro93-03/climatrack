import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';

class CreateWorkOrderPage extends StatefulWidget {
  const CreateWorkOrderPage({super.key});

  @override
  State<CreateWorkOrderPage> createState() => _CreateWorkOrderPageState();
}

class _CreateWorkOrderPageState extends State<CreateWorkOrderPage> {
  String? selectedClientId;
  String? selectedTechnicianId;
  String? selectedType;
  DateTime? selectedDate;
  final TextEditingController observationsController = TextEditingController();

  // Generar número correlativo usando counters/work_orders_2026 (campo last)
  Future<int> generarNumeroOrden() async {
    final counterRef = FirebaseFirestore.instance
        .collection("counters")
        .doc("work_orders_2026");

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int current = 0;
      if (snapshot.exists && snapshot.data()!.containsKey("last")) {
        current = snapshot["last"];
      }

      final newNumber = current + 1;

      transaction.set(counterRef, {"last": newNumber});

      return newNumber;
    });
  }

  // Crear orden
  Future<void> _createWorkOrder() async {
    if (selectedClientId == null ||
        selectedTechnicianId == null ||
        selectedType == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    // 1️Obtener contador
    final newNumber = await generarNumeroOrden();

    // 2️Formar número final EXACTO como tú pides
    final year = DateTime.now().year;
    final formatted = newNumber.toString().padLeft(4, "0");

    final numberString = "CLM-$year-$formatted";

    // 3️Guardar SOLO number como string
    await FirebaseFirestore.instance.collection("work_orders").add({
      "number": numberString, // STRING FINAL
      "client_id": selectedClientId,
      "technician_id": selectedTechnicianId,
      "type": selectedType,
      "scheduled_date": Timestamp.fromDate(selectedDate!),
      "observations": observationsController.text.trim(),
      "status": "pendiente",
      "created_at": Timestamp.now(),
      "started_at": null,
      "finished_at": null,
      "materials_used": [],
      "labor_cost": 0,
      "signature_url": "",
      "pdf_url": "",
      "visible_for_technician": true,
    });

    Navigator.pop(context, true);
  }

  // Selector de fecha
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        final base = Theme.of(context);

        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.black,
            ),
            dialogBackgroundColor: AppColors.background,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.background,
              headerBackgroundColor: AppColors.primary,
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppColors.black;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
              todayBackgroundColor: WidgetStateProperty.all(
                AppColors.primary.withOpacity(0.15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppTextStyles.body1,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Crear orden", style: AppTextStyles.h2w),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Seleccionar cliente
            Text("Cliente", style: AppTextStyles.h3),
            const SizedBox(height: 6),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("clients")
                  .orderBy("name")
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snap.data!.docs;

                return DropdownButtonFormField<String>(
                  value:
                      selectedClientId != null &&
                          docs.any((doc) => doc.id == selectedClientId)
                      ? selectedClientId
                      : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.greyLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 103, 108, 118),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: docs.map((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    final fullName = "${d["name"] ?? ""} ${d["lastname"] ?? ""}"
                        .trim();
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(fullName.isEmpty ? "Sin nombre" : fullName),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedClientId = v),
                );
              },
            ),

            const SizedBox(height: 20),

            // Seleccionar técnico
            Text("Técnico", style: AppTextStyles.h3),
            const SizedBox(height: 6),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .orderBy("name")
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snap.data!.docs;

                return DropdownButtonFormField<String>(
                  value:
                      selectedTechnicianId != null &&
                          docs.any((doc) => doc.id == selectedTechnicianId)
                      ? selectedTechnicianId
                      : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.greyLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 103, 108, 118),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: docs.map((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    final fullName = "${d["name"] ?? ""} ${d["lastname"] ?? ""}"
                        .trim();
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(fullName.isEmpty ? "Sin nombre" : fullName),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedTechnicianId = v),
                );
              },
            ),

            const SizedBox(height: 20),

            // Tipo de trabajo
            Text("Tipo de trabajo", style: AppTextStyles.h3),
            const SizedBox(height: 6),

            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.greyLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 103, 108, 118),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "gas_revision",
                  child: Text("Revisión del gas"),
                ),
                DropdownMenuItem(
                  value: "ac_installation",
                  child: Text("Instalación de aire acondicionado"),
                ),
                DropdownMenuItem(
                  value: "ac_repair",
                  child: Text("Reparación de aire acondicionado"),
                ),
                DropdownMenuItem(
                  value: "maintenance",
                  child: Text("Mantenimiento"),
                ),
              ],
              onChanged: (v) => setState(() => selectedType = v),
            ),

            const SizedBox(height: 20),

            // Fecha programada
            Text("Fecha programada", style: AppTextStyles.h3),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedDate == null
                      ? "Seleccionar fecha"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  style: AppTextStyles.body1,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Observaciones
            Text("Observaciones", style: AppTextStyles.h3),
            const SizedBox(height: 6),

            TextField(
              controller: observationsController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 40),

            // Crear orden
            AppButtons.primary(
              text: "Crear orden",
              width: double.infinity,
              onPressed: _createWorkOrder,
            ),
          ],
        ),
      ),
    );
  }
}
