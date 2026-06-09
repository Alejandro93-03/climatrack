import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clima_track/repository/work_order_assignment_repository.dart';

/// Provider que gestiona la lógica de asignación de trabajos a instaladores.
/// Sigue el patrón Provider + Repository definido en la guía del proyecto.
class WorkOrderAssignmentProvider extends ChangeNotifier {
  final WorkOrderAssignmentRepository _repository =
      WorkOrderAssignmentRepository();

  /// Lista de trabajos del instalador para un día concreto
  List<Map<String, dynamic>> _workOrdersForDay = [];

  /// Indica si hay una operación en curso
  bool _isLoading = false;

  /// Mensaje de error si algo falla
  String? _errorMessage;

  List<Map<String, dynamic>> get workOrdersForDay => _workOrdersForDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga los trabajos de un instalador para un día concreto.
  /// Útil para que el admin vea la disponibilidad del instalador.
  Future<void> loadWorkOrdersForDay(
    String technicianId,
    DateTime date,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workOrdersForDay = await _repository.getWorkOrdersByInstallerAndDate(
        technicianId,
        date,
      );
    } catch (e) {
      _errorMessage = 'Error al cargar los trabajos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Devuelve un Stream con todos los trabajos en tiempo real.
  /// El admin puede ver el estado de todos los trabajos actualizándose solo.
  Stream<QuerySnapshot> getAllWorkOrdersStream() {
    return _repository.getAllWorkOrdersStream();
  }

  /// Asigna un trabajo a un instalador.
  Future<void> assignWorkOrder({
    required String workOrderId,
    required String technicianId,
    required DateTime scheduledDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.assignWorkOrder(
        workOrderId: workOrderId,
        technicianId: technicianId,
        scheduledDate: scheduledDate,
      );
    } catch (e) {
      _errorMessage = 'Error al asignar el trabajo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el estado de un trabajo.
  /// El flujo es: pendiente → en_ruta → en_curso → pendiente_firma → completado
  Future<void> updateWorkOrderStatus({
    required String workOrderId,
    required String newStatus,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateWorkOrderStatus(
        workOrderId: workOrderId,
        newStatus: newStatus,
      );
    } catch (e) {
      _errorMessage = 'Error al actualizar el estado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}