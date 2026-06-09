import 'package:clima_track/models/material.dart';
import 'package:clima_track/models/work_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkOrderRepository {
  final _db = FirebaseFirestore.instance;

  // Partes asignados a un técnico
  Stream<List<WorkOrder>> getWorkOrdersForTech(String techId) {
    return _db
        .collection('work_orders')
        .where('technician_id', isEqualTo: techId)
        .where("visible_for_technician", isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            return WorkOrder.fromMap(data, doc.id);
          }).toList(),
        );
  }

  /// Añadir material al parte
  Future<void> addMaterialToWorkOrder({
    required String workOrderId,
    required Material material,
    required int quantity,
  }) async {
    final subtotal = material.unitPrice * quantity;

    await _db.collection('work_orders').doc(workOrderId).update({
      'materials_used': FieldValue.arrayUnion([
        {
          'material_id': material.id,
          'name': material.name,
          'quantity': quantity,
          'unit_price': material.unitPrice,
          'subtotal': subtotal,
        },
      ]),
    });
  }

  /// CLM 62 - actualizar estado + historialEstados
  Future<void> updateWorkOrderStatus({
    required String workOrderId,
    required String newStatus,
    required String technicianId,
  }) async {
    final now = Timestamp.fromDate(DateTime.now());

    await _db.collection('work_orders').doc(workOrderId).update({
      'status': newStatus,
      'historialEstados': FieldValue.arrayUnion([
        {'estado': newStatus, 'timestamp': now, 'tecnico_id': technicianId},
      ]),
    });
  }

  /// Actualizar fecha/hora tras Drag & Drop
  Future<void> updateWorkOrderSchedule({
    required String workOrderId,
    required DateTime newDate,
  }) async {
    await _db.collection('work_orders').doc(workOrderId).update({
      'scheduled_date': Timestamp.fromDate(newDate),
    });
  }
}
