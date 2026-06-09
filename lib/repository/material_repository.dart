import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/material.dart';

// Lee materiales activos del catálogo
// Obtiene un material por ID
// Permite crear, actualizar y desactivar materiales
// Este repositorio lo usa MaterialProvider
class MaterialRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtiene todos los materiales activos del catálogo
  Stream<List<Material>> getMaterials() {
    return _db
        .collection('materials')
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Material.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Obtiene un material por su ID
  Future<Material?> getMaterialById(String id) async {
    final doc = await _db.collection('materials').doc(id).get();
    if (!doc.exists) return null;
    return Material.fromMap(doc.data()!, doc.id);
  }

  /// Crea un nuevo material en Firestore
  Future<void> createMaterial(Material material) async {
    await _db.collection('materials').add(material.toMap());
  }

  /// Actualiza un material existente
  Future<void> updateMaterial(Material material) async {
    await _db.collection('materials').doc(material.id).update(material.toMap());
  }

  /// Desactiva un material (no se borra, solo deja de aparecer)
  Future<void> deactivateMaterial(String id) async {
    await _db.collection('materials').doc(id).update({'is_active': false});
  }
}
