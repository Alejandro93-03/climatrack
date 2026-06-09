import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clima_track/services/notification_service.dart';

/// Repositorio que gestiona la lógica de asignación de trabajos a instaladores.
/// Sigue el patrón Repository definido en la guía del proyecto.
class WorkOrderAssignmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene los trabajos asignados a un instalador en una fecha concreta.
  /// Útil para que el admin vea la disponibilidad del instalador ese día.
  Future<List<Map<String, dynamic>>> getWorkOrdersByInstallerAndDate(
    String technicianId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('work_orders')
        .where('technician_id', isEqualTo: technicianId)
        .where('scheduled_date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduled_date',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Obtiene todos los trabajos en tiempo real para el admin.
  /// Devuelve un Stream que se actualiza automáticamente cuando hay cambios.
  Stream<QuerySnapshot> getAllWorkOrdersStream() {
    return _firestore
        .collection('work_orders')
        .orderBy('scheduled_date', descending: false)
        .snapshots();
  }

  /// Asigna un trabajo a un instalador y le envía una notificación.
  Future<void> assignWorkOrder({
    required String workOrderId,
    required String technicianId,
    required DateTime scheduledDate,
  }) async {
    /// Actualizar el trabajo en Firestore
    await _firestore.collection('work_orders').doc(workOrderId).update({
      'technician_id': technicianId,
      'scheduled_date': Timestamp.fromDate(scheduledDate),
      'status': 'pendiente',
    });

    /// Notificar al instalador via topic
    await NotificationService.subscribeToTopic('installer_$technicianId');
  }

  /// Actualiza el estado de un trabajo.
  /// El flujo es: pendiente → en_ruta → en_curso → pendiente_firma → completado
  Future<void> updateWorkOrderStatus({
    required String workOrderId,
    required String newStatus,
  }) async {
    final validStatuses = [
      'pendiente',
      'en_ruta',
      'en_curso',
      'pendiente_firma',
      'completado',
      'nadie_en_casa',
      'facturado',
    ];

    if (!validStatuses.contains(newStatus)) {
      throw Exception('Estado no válido: $newStatus');
    }

    await _firestore.collection('work_orders').doc(workOrderId).update({
      'status': newStatus,
      if (newStatus == 'en_curso') 'started_at': Timestamp.now(),
      if (newStatus == 'completado') 'finished_at': Timestamp.now(),
    });
  }
}