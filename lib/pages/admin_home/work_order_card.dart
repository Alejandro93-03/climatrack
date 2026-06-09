import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';

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

class WorkOrderCard extends StatelessWidget {
  final String orderId;
  final String orderCode; // 🔥 ahora debe venir de order_code
  final String clientId;
  final String type;
  final String status;
  final DateTime? scheduledDate;
  final VoidCallback onTap;

  const WorkOrderCard({
    super.key,
    required this.orderId,
    required this.orderCode,
    required this.clientId,
    required this.type,
    required this.status,
    required this.scheduledDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> statusLabels = {
      "pendiente": "Pendiente",
      "en_curso": "En curso",
      "completado": "Completado",
      "cancelado": "Cancelado",
      "nadie_en_casa": "Nadie en casa",
      "facturado": "Facturado",
    };

    final estadoLabel = statusLabels[status] ?? status;
    final statusColor = getStatusColor(status);

    final fechaStr = scheduledDate != null
        ? "${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}  "
              "${scheduledDate!.hour.toString().padLeft(2, '0')}:"
              "${scheduledDate!.minute.toString().padLeft(2, '0')}"
        : "Sin fecha";

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------
            // 🔵 CABECERA AZUL (código + estado dinámico)
            // ---------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔥 Código de orden (CLM-2026-0001)
                  Text(
                    orderCode,
                    style: AppTextStyles.h3w.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 🔥 BADGE: fondo dinámico + texto blanco
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor, // FONDO DEL COLOR DEL ESTADO
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      estadoLabel.toUpperCase(),
                      style: AppTextStyles.body2w.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // TEXTO SIEMPRE BLANCO
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------
            // 🔽 CONTENIDO
            // ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------------------------------------------
                  // 👤 CLIENTE + FECHA
                  // ---------------------------------------------------------
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("clients")
                        .doc(clientId)
                        .get(),
                    builder: (context, snap) {
                      final fechaWidget = Text(
                        fechaStr,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.greyDark,
                          fontWeight: FontWeight.w600,
                        ),
                      );

                      if (!snap.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Cargando cliente...",
                                  style: AppTextStyles.body1.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            fechaWidget,
                          ],
                        );
                      }

                      final data = snap.data!.data() as Map<String, dynamic>?;

                      final name = data?["name"] ?? "";
                      final lastname = data?["lastname"] ?? "";

                      return Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "$name $lastname",
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          fechaWidget,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // ---------------------------------------------------------
                  // 🔧 TÉCNICO
                  // ---------------------------------------------------------
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("work_orders")
                        .doc(orderId)
                        .get(),
                    builder: (context, orderSnap) {
                      if (!orderSnap.hasData) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.build,
                              color: Colors.orange,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Cargando técnico...",
                              style: AppTextStyles.body1.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        );
                      }

                      final orderData =
                          orderSnap.data!.data() as Map<String, dynamic>?;

                      final techId = orderData?["technician_id"];

                      if (techId == null || techId == "") {
                        return Row(
                          children: [
                            const Icon(
                              Icons.build,
                              color: Colors.orange,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Técnico no asignado",
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(techId)
                            .get(),
                        builder: (context, techSnap) {
                          if (!techSnap.hasData) {
                            return Row(
                              children: [
                                const Icon(
                                  Icons.build,
                                  color: Colors.orange,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Cargando técnico...",
                                  style: AppTextStyles.body1.copyWith(
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            );
                          }

                          final techData =
                              techSnap.data!.data() as Map<String, dynamic>?;

                          final techName = techData?["name"] ?? "";
                          final techLastname = techData?["lastname"] ?? "";

                          return Row(
                            children: [
                              const Icon(
                                Icons.build,
                                color: Colors.orange,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$techName $techLastname",
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
