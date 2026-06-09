import 'package:clima_track/pages/agenda_dia/widgets_agenda_dia/work_order_item.dart';
import 'package:flutter/material.dart';
import '../../providers/agenda_provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../models/work_order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Muestra al técnico autenticado la lista de partes asignados para hoy.
// La pantalla escucha el Stream proporcionado por AgendaProvider, que a su vez
// obtiene los datos desde WorkOrderRepository.
// Esta pantalla no tiene lógica de negocio, solo construye la interfaz.
class AgendaDiaPage extends StatelessWidget {
  const AgendaDiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final techId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Agenda del Día", style: AppTextStyles.h2w),
        centerTitle: true,
      ),
      body: StreamBuilder<List<WorkOrder>>(
        stream: context.read<AgendaProvider>().getWorkOrders(techId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return Center(
              child: Text(
                "No tienes partes asignados hoy",
                style: AppTextStyles.body1,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, i) => WorkOrderItem(order: orders[i]),
          );
        },
      ),
    );
  }
}
