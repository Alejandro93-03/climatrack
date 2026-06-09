import 'package:flutter/material.dart';
import '../models/work_order.dart';
import '../repository/work_order_repository.dart';

// Provider encargado de gestionar el estado de la Agenda del Día.
// Su única responsabilidad es exponer un Stream de WorkOrders
// filtrados por el técnico autenticado.
// La lógica de acceso a Firestore está en work_order_repository
class AgendaProvider extends ChangeNotifier {
  final WorkOrderRepository _repo = WorkOrderRepository();

  // Devuelve un Stream con los partes asignados al técnico indicado
  Stream<List<WorkOrder>> getWorkOrders(String techId) {
    return _repo.getWorkOrdersForTech(techId);
  }
}
