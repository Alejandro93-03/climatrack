import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide Material;
// material.dart de flutter está en HIDE porque hay choque (mismo nombre)
import '../models/material.dart';
import '../repository/work_order_repository.dart';

class WorkOrderProvider extends ChangeNotifier {
  final WorkOrderRepository _repo = WorkOrderRepository();

  /// Añade un material al parte
  Future<void> addMaterialToWorkOrder(
    String workOrderId,
    Material material,
    int quantity,
  ) async {
    await _repo.addMaterialToWorkOrder(
      workOrderId: workOrderId,
      material: material,
      quantity: quantity,
    );

    notifyListeners(); // Para refrescar la UI si la pantalla escucha al provider
  }

  /// Elimina un material del parte (por material_id)
  Future<void> removeMaterialFromWorkOrder(
    String workOrderId,
    String materialId,
  ) async {
    final docRef = FirebaseFirestore.instance
        .collection('work_orders')
        .doc(workOrderId);

    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final List materials = List<Map<String, dynamic>>.from(
      data['materials_used'] ?? [],
    );

    // Filtrar todos los materiales excepto el que queremos borrar
    final updated = materials
        .where((m) => m['material_id'] != materialId)
        .toList();

    await docRef.update({'materials_used': updated});

    notifyListeners();
  }

  // CLM 62 (historialEstados)
  Future<void> updateStatus(
    String workOrderId,
    String newStatus,
    String technicianId,
  ) async {
    await _repo.updateWorkOrderStatus(
      workOrderId: workOrderId,
      newStatus: newStatus,
      technicianId: technicianId,
    );
    notifyListeners();
  }
}
