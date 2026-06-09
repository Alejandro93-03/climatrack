import 'package:clima_track/pages/admin_home/work_order_card.dart';
import 'package:clima_track/pages/parte_trabajo_form/widgets/estado_selector_modal.dart';
import 'package:clima_track/pages/parte_trabajo_form/widgets/material_selector_modal.dart';
import 'package:clima_track/providers/work_order_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';

class ParteTrabajoForm extends StatefulWidget {
  final String workOrderId;

  const ParteTrabajoForm({super.key, required this.workOrderId});

  @override
  State<ParteTrabajoForm> createState() => _ParteTrabajoFormState();
}

class _ParteTrabajoFormState extends State<ParteTrabajoForm> {
  String currentStatus = "pendiente";
  final _formKey = GlobalKey<FormState>();

  final _descripcionController = TextEditingController();

  final _nombreCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _unidadCtrl = TextEditingController();
  List<Map<String, dynamic>> materiales = [];

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  final Set<String> _servicios = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _unidadCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentStatus() async {
    final snap = await FirebaseFirestore.instance
        .collection('work_orders')
        .doc(widget.workOrderId)
        .get();

    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    setState(() {
      currentStatus = data['status'] ?? 'pendiente';
    });
  }

  Widget _buildServicioButton({
    required String key,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final bool selected = _servicios.contains(key);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (selected) {
              _servicios.remove(key);
            } else {
              _servicios.add(key);
            }
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: selected ? activeColor : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: activeColor, width: selected ? 2 : 1.5),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? activeColor.withOpacity(0.25)
                    : Colors.grey.withOpacity(0.15),
                blurStyle: selected ? BlurStyle.inner : BlurStyle.normal,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : activeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.body1.copyWith(
                  color: selected ? Colors.white : activeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Parte de trabajo', style: AppTextStyles.h2w),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tipo de servicio", style: AppTextStyles.body2),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildServicioButton(
                        key: "gas",
                        label: "Gas",
                        icon: Icons.local_fire_department,
                        activeColor: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      _buildServicioButton(
                        key: "ac",
                        label: "Aire Acond.",
                        icon: Icons.ac_unit,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text("Descripción del trabajo *", style: AppTextStyles.body2),
                  const SizedBox(height: 8),

                  AppInputs.primaryMultiline(
                    placeholder: "Describe el trabajo realizado",
                    controller: _descripcionController,
                    width: double.infinity,
                    maxLines: 5,
                    validator: (value) =>
                        value!.isEmpty ? "Este campo es obligatorio" : null,
                  ),

                  const SizedBox(height: 28),

                  Text("Materiales utilizados", style: AppTextStyles.body2),
                  const SizedBox(height: 12),

                  AppButtons.withIconPrimary(
                    text: "Añadir material",
                    icon: Icons.add,
                    width: double.infinity,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => MaterialSelectorModal(
                          workOrderId: widget.workOrderId,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('work_orders')
                        .doc(widget.workOrderId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;

                      if (data == null || data['materials_used'] == null) {
                        return const Text(
                          "No hay materiales añadidos todavía.",
                        );
                      }

                      final List materials = data['materials_used'];

                      if (materials.isEmpty) {
                        return const Text(
                          "No hay materiales añadidos todavía.",
                        );
                      }

                      return Column(
                        children: materials.map((m) {
                          final name = m['name'];
                          final qty = m['quantity'];
                          final unitPrice = m['unit_price'];
                          final subtotal = m['subtotal'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.25),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                                const SizedBox(width: 12),

                                // Texto del material
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: AppTextStyles.body1.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$qty uds — ${unitPrice.toStringAsFixed(2)}€ c/u",
                                        style: AppTextStyles.body2.copyWith(
                                          color: AppColors.greyDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Subtotal: ${subtotal.toStringAsFixed(2)}€",
                                        style: AppTextStyles.body1.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Botón eliminar
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await context
                                        .read<WorkOrderProvider>()
                                        .removeMaterialFromWorkOrder(
                                          widget.workOrderId,
                                          m['material_id'],
                                        );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  ...materiales.map(
                    (m) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${m['nombre']} — ${m['cantidad']} ${m['unidad']}",
                            style: AppTextStyles.body1,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => materiales.remove(m));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Título con icono
                  Row(
                    children: [
                      Icon(
                        Icons.border_color,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Firma del cliente",
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Contenedor premium
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.35),
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Área de firma
                        Signature(
                          controller: _signatureController,
                          backgroundColor: AppColors.background,
                        ),

                        // Texto guía cuando está vacío
                        if (_signatureController.isEmpty)
                          Center(
                            child: Text(
                              "Firme aquí",
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.greyDark.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Botón borrar firma mejorado
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _signatureController.clear(),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        "Borrar firma",
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  AppButtons.withIconPrimary(
                    text: "Guardar parte",
                    icon: Icons.save,
                    width: double.infinity,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(
                          Navigator.of(context).overlay!.context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text("El estado se ha actualizado"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  Text("Estado actual", style: AppTextStyles.h2),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(currentStatus).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: getStatusColor(currentStatus),
                        width: 1.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 14,
                          color: getStatusColor(currentStatus),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          currentStatus.toUpperCase(),
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: getStatusColor(currentStatus),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  AppButtons.withIconPrimary(
                    text: "Cambiar estado",
                    icon: Icons.sync_alt,
                    width: double.infinity,
                    onPressed: () async {
                      final nuevoEstado = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) => EstadoSelectorModal(
                          workOrderId: widget.workOrderId,
                          currentStatus: currentStatus,
                        ),
                      );

                      if (nuevoEstado != null) {
                        setState(() {
                          currentStatus = nuevoEstado;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
