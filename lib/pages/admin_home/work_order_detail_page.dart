import 'package:clima_track/pages/admin_home/assign_work_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';

/// 🔥 Color dinámico según estado (solo AppColors)
Color getStatusColor(String status) {
  switch (status) {
    case "pendiente":
      return AppColors.warning;
    case "en_curso":
      return AppColors.info;
    case "completado":
      return AppColors.success;
    case "cancelado":
      return AppColors.error;
    case "nadie_en_casa":
      return AppColors.greyDark;
    case "facturado":
      return AppColors.successDark;
    default:
      return AppColors.primary;
  }
}

class WorkOrderDetailPage extends StatelessWidget {
  final String orderId;

  const WorkOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Detalle de la orden", style: AppTextStyles.h2w),
        centerTitle: true,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("work_orders")
            .doc(orderId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.data!.exists) {
            return const Center(child: Text("La orden ya no existe"));
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          final Map<String, String> workTypeLabels = {
            "gas_revision": "Revisión del gas",
            "ac_install": "Instalación de aire acondicionado",
            "ac_installation": "Instalación de aire acondicionado",
            "ac_repair": "Reparación de aire acondicionado",
            "maintenance": "Mantenimiento",
          };

          final Map<String, String> statusLabels = {
            "pendiente": "Pendiente",
            "en_curso": "En curso",
            "completado": "Completado",
            "cancelado": "Cancelado",
            "nadie_en_casa": "Nadie en casa",
            "facturado": "Facturado",
          };

          final tipoTrabajo =
              workTypeLabels[data["type"]] ?? data["type"] ?? "Desconocido";

          final estadoLabel =
              statusLabels[data["status"]] ?? data["status"] ?? "Desconocido";

          final statusColor = getStatusColor(data["status"]);

          final fecha = (data["scheduled_date"] as Timestamp?)?.toDate();
          final fechaStr = fecha != null
              ? "${fecha.day}/${fecha.month}/${fecha.year}  "
                    "${fecha.hour.toString().padLeft(2, '0')}:"
                    "${fecha.minute.toString().padLeft(2, '0')}"
              : "Sin fecha";

          final clientId = data["client_id"];
          final technicianId = data["technician_id"];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // ---------------------------------------------------------
                // 🔵 CABECERA INDUSTRIAL (centrada)
                // ---------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "ORDEN Nº ${data["number"]}",
                      style: AppTextStyles.h2w.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------------------
                // 👤 CLIENTE
                // ---------------------------------------------------------
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("clients")
                      .doc(clientId)
                      .get(),
                  builder: (context, clientSnap) {
                    if (!clientSnap.hasData) {
                      return _infoRow(
                        icon: Icons.person,
                        title: "Cliente",
                        value: "Cargando...",
                        color: AppColors.primary,
                      );
                    }

                    final clientData =
                        clientSnap.data!.data() as Map<String, dynamic>?;

                    if (clientData == null) {
                      return _infoRow(
                        icon: Icons.person,
                        title: "Cliente",
                        value: "Desconocido",
                        color: AppColors.error,
                      );
                    }

                    final clientName = clientData["name"] ?? "Sin nombre";
                    final clientLastname = clientData["lastname"] ?? "";
                    final clientAddress =
                        clientData["address"] ?? "Sin dirección";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(
                          icon: Icons.person,
                          title: "Cliente",
                          value: "$clientName $clientLastname",
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        _infoRow(
                          icon: Icons.home,
                          title: "Dirección",
                          value: clientAddress,
                          color: AppColors.greyDark,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------------------
                // 🔧 TÉCNICO
                // ---------------------------------------------------------
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(technicianId)
                      .get(),
                  builder: (context, techSnap) {
                    if (!techSnap.hasData) {
                      return _infoRow(
                        icon: Icons.build,
                        title: "Técnico",
                        value: "Cargando...",
                        color: Colors.orange,
                      );
                    }

                    final techData =
                        techSnap.data!.data() as Map<String, dynamic>?;

                    if (techData == null) {
                      return _infoRow(
                        icon: Icons.build,
                        title: "Técnico",
                        value: "No asignado",
                        color: Colors.orange,
                      );
                    }

                    final techName = techData["name"] ?? "";
                    final techLastname = techData["lastname"] ?? "";

                    return _infoRow(
                      icon: Icons.build,
                      title: "Técnico",
                      value: "$techName $techLastname",
                      color: Colors.orange,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------------------
                // 🛠️ TIPO DE TRABAJO
                // ---------------------------------------------------------
                _infoRow(
                  icon: Icons.work,
                  title: "Tipo de trabajo",
                  value: tipoTrabajo,
                  color: AppColors.black,
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------------------
                // 📌 ESTADO (badge dinámico)
                // ---------------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag, color: AppColors.black, size: 26),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔵 TÍTULO NORMAL (NO DINÁMICO)
                          Text(
                            "Estado",
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.black,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // 🔥 BADGE IGUAL AL DE WorkOrderCard
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor, // fondo dinámico
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              estadoLabel.toUpperCase(),
                              style: AppTextStyles.body2w.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // texto blanco
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------------------
                // 📅 FECHA PROGRAMADA
                // ---------------------------------------------------------
                _infoRow(
                  icon: Icons.calendar_month,
                  title: "Fecha programada",
                  value: fechaStr,
                  color: AppColors.greyDark,
                ),

                const SizedBox(height: 20),

                // -------------------------------------------------------------
                // HISTORIAL DE ESTADOS
                // -------------------------------------------------------------
                const SizedBox(height: 20),
                Text("Historial de estados", style: AppTextStyles.h2),

                const SizedBox(height: 12),

                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("work_orders")
                      .doc(orderId)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snap.data!.data() as Map<String, dynamic>?;

                    if (data == null || data["historialEstados"] == null) {
                      return Text(
                        "Sin historial",
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.greyDark,
                        ),
                      );
                    }

                    final List historial = data["historialEstados"];

                    if (historial.isEmpty) {
                      return Text(
                        "Sin historial",
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.greyDark,
                        ),
                      );
                    }

                    // Ordenar por timestamp ascendente
                    historial.sort((a, b) {
                      final ta =
                          (a["timestamp"] as Timestamp?)?.toDate() ??
                          DateTime(2000);
                      final tb =
                          (b["timestamp"] as Timestamp?)?.toDate() ??
                          DateTime(2000);
                      return ta.compareTo(tb);
                    });

                    return Column(
                      children: historial.map((item) {
                        final estado = item["estado"] ?? "desconocido";
                        final fecha = (item["timestamp"] as Timestamp?)
                            ?.toDate();
                        final tecnicoId = item["tecnico_id"] ?? "";

                        final fechaStr = fecha != null
                            ? "${fecha.day}/${fecha.month}/${fecha.year} "
                                  "${fecha.hour.toString().padLeft(2, '0')}:"
                                  "${fecha.minute.toString().padLeft(2, '0')}"
                            : "Fecha desconocida";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              // Icono del estado
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: getStatusColor(estado),
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Texto principal
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      estado.toUpperCase(),
                                      style: AppTextStyles.body1.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: getStatusColor(estado),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fechaStr,
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.greyDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Técnico (opcional)
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(tecnicoId)
                                    .get(),
                                builder: (context, techSnap) {
                                  if (!techSnap.hasData ||
                                      !techSnap.data!.exists) {
                                    return const SizedBox();
                                  }

                                  final tData =
                                      techSnap.data!.data()
                                          as Map<String, dynamic>?;

                                  final nombre = tData?["name"] ?? "";
                                  final apellido = tData?["lastname"] ?? "";

                                  return Text(
                                    "$nombre $apellido",
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.primary,
                                    ),
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

                // ---------------------------------------------------------
                // 📝 OBSERVACIONES
                // ---------------------------------------------------------
                Text(
                  "Observaciones",
                  style: AppTextStyles.h3.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  data["observations"] ?? "",
                  style: AppTextStyles.body1.copyWith(fontSize: 18),
                ),

                const SizedBox(height: 40),

                // ---------------------------------------------------------
                // 🔄 CAMBIAR TÉCNICO
                // ---------------------------------------------------------
                AppButtons.primary(
                  text: "Cambiar técnico",
                  width: double.infinity,
                  onPressed: () async {
                    final changed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AssignWorkModal(orderId: orderId),
                    );

                    if (changed == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Técnico reasignado correctamente"),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------------------
                // 🗑️ ELIMINAR ORDEN
                // ---------------------------------------------------------
                AppButtons.primaryDelete(
                  text: "Eliminar orden",
                  width: double.infinity,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Eliminar orden", style: AppTextStyles.h2),
                                const SizedBox(height: 16),

                                Text(
                                  "¿Seguro que quieres eliminar esta orden? Esta acción no se puede deshacer.",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body1,
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    AppButtons.outlinedPrimary(
                                      text: "Cancelar",
                                      width: 120,
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                    AppButtons.primaryDelete(
                                      text: "Eliminar",
                                      width: 120,
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection("work_orders")
                          .doc(orderId)
                          .delete();

                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔧 WIDGET REUTILIZABLE PARA FILAS DE INFORMACIÓN
  // ---------------------------------------------------------
  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body2.copyWith(color: color, fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
