import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import 'edit_installation_page.dart';
import 'edit_client_page.dart';

class ClientDetailsPage extends StatefulWidget {
  final String clientId;
  final bool isAdmin;

  const ClientDetailsPage({
    super.key,
    required this.clientId,
    required this.isAdmin,
  });

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  bool get isAdmin => widget.isAdmin;

  // ───────────────────────────────────────────────
  // ELIMINAR CLIENTE
  // ───────────────────────────────────────────────
  Future<void> _deleteClient() async {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(widget.clientId)
        .delete();

    if (mounted) Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Eliminar cliente",
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),

                const SizedBox(height: 12),

                Text(
                  "¿Seguro que quieres eliminar este cliente?",
                  style: AppTextStyles.body1,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: AppButtons.grey(
                        text: "Cancelar",
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButtons.primaryDelete(
                        text: "Eliminar",
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteClient();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // ELIMINAR INSTALACIÓN
  // ───────────────────────────────────────────────
  void _confirmDeleteInstallation(int index) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Eliminar instalación",
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  "¿Seguro que quieres eliminar esta instalación?",
                  style: AppTextStyles.body1,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButtons.grey(
                        text: "Cancelar",
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButtons.primaryDelete(
                        text: "Eliminar",
                        onPressed: () async {
                          Navigator.pop(context);

                          final doc = await FirebaseFirestore.instance
                              .collection('clients')
                              .doc(widget.clientId)
                              .get();

                          final data = doc.data() as Map<String, dynamic>;

                          final installations = List<Map<String, dynamic>>.from(
                            data['installations'] ?? [],
                          );

                          installations.removeAt(index);

                          await FirebaseFirestore.instance
                              .collection('clients')
                              .doc(widget.clientId)
                              .update({'installations': installations});
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // AÑADIR INSTALACIÓN
  // ───────────────────────────────────────────────
  Future<void> _openAddInstallation() async {
    if (!isAdmin) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditInstallationPage(
          clientId: widget.clientId,
          installation: null,
          returnMode: false,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // UI PRINCIPAL
  // ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Detalles del cliente", style: AppTextStyles.h2w),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      // BOTÓN FIJO ABAJO (solo admin)
      bottomNavigationBar: isAdmin
          ? SafeArea(
              minimum: const EdgeInsets.all(20),
              child: AppButtons.primaryDelete(
                text: "Eliminar cliente",
                width: double.infinity,
                onPressed: _confirmDelete,
              ),
            )
          : null,

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clients')
            .doc(widget.clientId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data["name"] ?? "Sin nombre";
          final email = data["email"] ?? "Sin email";
          final address = data["address"] ?? "Sin dirección";
          final installations = (data["installations"] as List?) ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 DATOS DEL CLIENTE
                Text(name, style: AppTextStyles.h2),
                const SizedBox(height: 6),
                Text(email, style: AppTextStyles.body1),
                Text(address, style: AppTextStyles.body1),

                const SizedBox(height: 20),

                // 🔥 BOTÓN EDITAR CLIENTE
                if (isAdmin)
                  AppButtons.primary(
                    text: "Editar cliente",
                    width: double.infinity,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditClientPage(
                            clientId: widget.clientId,
                            initialData: data,
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 30),

                // LISTA DE INSTALACIONES
                Text("Instalaciones", style: AppTextStyles.h2),
                const SizedBox(height: 10),

                if (installations.isEmpty)
                  Text(
                    "No hay instalaciones registradas",
                    style: AppTextStyles.body1,
                  ),

                ...installations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final inst = entry.value;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: isAdmin
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditInstallationPage(
                                        clientId: widget.clientId,
                                        installation: inst,
                                        returnMode: false,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${inst['type']} - ${inst['brand']}",
                                        style: AppTextStyles.body1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Modelo: ${inst['model']}",
                                        style: AppTextStyles.body2,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAdmin)
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      if (isAdmin)
                        GestureDetector(
                          onTap: () => _confirmDeleteInstallation(index),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),

                const SizedBox(height: 20),

                if (isAdmin)
                  AppButtons.secondary(
                    text: "Añadir instalación",
                    width: double.infinity,
                    onPressed: _openAddInstallation,
                  ),

                // ESPACIO EXTRA PARA QUE EL SCROLL NO CHOQUE CON EL BOTÓN FIJO
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
