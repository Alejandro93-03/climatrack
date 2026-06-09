import 'package:clima_track/models/client.dart';
import 'package:clima_track/pages/admin_home/work_order_card.dart';
import 'package:clima_track/pages/parte_trabajo_form/parte_trabajo_form.dart';
import 'package:clima_track/repository/client_repository.dart';
import 'package:clima_track/widgets/app_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_textstyles.dart';
import '../../../models/work_order.dart';

// Widget visual que representa un parte de trabajo dentro de la Agenda del día.
// Muestra información básica del WorkOrder (númerp del parte, tipo de trabajo, estado, fecha, etc.).
class WorkOrderItem extends StatefulWidget {
  final WorkOrder order;

  const WorkOrderItem({super.key, required this.order});

  @override
  State<WorkOrderItem> createState() => _WorkOrderItemState();
}

class _WorkOrderItemState extends State<WorkOrderItem> {
  Client? client;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    final repo = ClientRepository();
    final c = await repo.getClientById(widget.order.clientId);

    setState(() {
      client = c;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número del parte
          Text(widget.order.number, style: AppTextStyles.h3),

          const SizedBox(height: 6),

          // Cliente y dirección
          Text(
            "Cliente: ${client?.name ?? 'Desconocido'}",
            style: AppTextStyles.body2,
          ),
          Text(
            "Dirección: ${client?.address ?? 'Sin dirección'}",
            style: AppTextStyles.body2,
          ),

          const SizedBox(height: 6),

          // Tipo, estado y hora
          Text("Tipo: ${widget.order.type}", style: AppTextStyles.body2),
          // Reutilización de estados con colores
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(widget.order.status),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.order.status.toUpperCase(),
              style: AppTextStyles.body2w,
            ),
          ),

          Text(
            "Hora: ${widget.order.scheduledDate.hour.toString().padLeft(2, '0')}:${widget.order.scheduledDate.minute.toString().padLeft(2, '0')}",
            style: AppTextStyles.body2,
          ),

          const SizedBox(height: 12),

          // Botón iniciar trabajo
          // Botón iniciar trabajo (solo si está pendiente)
          if (widget.order.status == "pendiente") ...[
            AppButtons.withIconPrimary(
              text: "Iniciar trabajo",
              icon: Icons.play_arrow,
              width: double.infinity,
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('work_orders')
                    .doc(widget.order.id)
                    .update({
                      'status': 'en_curso',
                      'started_at': Timestamp.now(),
                    });
              },
            ),

            const SizedBox(height: 8),
          ],

          const SizedBox(height: 8),

          // Botón abrir parte
          AppButtons.secondary(
            text: "Abrir parte",
            width: double.infinity,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParteTrabajoForm(
                    workOrderId: widget.order.id, // 👈 IMPORTANTE
                  ),
                ),
              );
            },
          ),
          // Botón FINALIZAR (solo si está facturado)
          if (widget.order.status == "facturado") ...[
            const SizedBox(height: 8),

            AppButtons.withIconPrimary(
              text: "Finalizar",
              icon: Icons.check_circle,
              width: double.infinity,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Trabajo finalizado"),
                    content: const Text(
                      "Este parte ya está facturado. ¿Deseas finalizarlo?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("work_orders")
                              .doc(widget.order.id)
                              .update({
                                "visible_for_technician": false,
                                "finished_at": Timestamp.now(),
                              });

                          Navigator.pop(context);
                        },
                        child: const Text("Finalizar"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
