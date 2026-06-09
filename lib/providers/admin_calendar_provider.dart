import 'package:flutter/material.dart';
import '../repository/work_order_repository.dart';

class AdminCalendarProvider extends ChangeNotifier {
  final WorkOrderRepository _repository = WorkOrderRepository();
  bool _isUpdating = false;

  bool get isUpdating => _isUpdating;

  // Método para mover un trabajo en la agenda
  Future<void> reorderWorkOrder(String workOrderId, DateTime newDate) async {
    _isUpdating = true;
    notifyListeners(); // Notifica a la UI que estamos cargando [cite: 108]

    try {
      // Llamada al repositorio para persistir el cambio en Firestore [cite: 104]
      await _repository.updateWorkOrderSchedule(
        workOrderId: workOrderId,
        newDate: newDate,
      );
    } catch (e) {
      debugPrint("Error al reordenar: $e");
    } finally {
      _isUpdating = false;
      notifyListeners(); // Actualiza la UI tras finalizar [cite: 109]
    }
  }
}
