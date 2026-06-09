import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
/// según el tipo de trabajo, leyendo los valores desde Firestore.
class WorkTypeDurationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene la duración estimada en minutos para un tipo de trabajo.
  /// Si el tipo no existe en Firestore, devuelve 60 minutos por defecto.
  Future<int> getDurationForType(String workType) async {
    try {
      final doc = await _firestore
          .collection('work_type_durations')
          .doc(workType)
          .get();

      if (doc.exists) {
        return (doc.data()!['duration_minutes'] as int);
      }

      /// Si no existe el tipo, devuelve 60 minutos por defecto
      return 60;
    } catch (e) {
      /// En caso de error, devuelve 60 minutos por defecto
      return 60;
    }
  }

  /// Obtiene todos los tipos de trabajo con sus duraciones.
  /// Útil para mostrar al Admin el mapa completo de duraciones.
  Future<Map<String, int>> getAllDurations() async {
    try {
      final snapshot =
          await _firestore.collection('work_type_durations').get();

      return {
        for (var doc in snapshot.docs)
          doc.id: (doc.data()['duration_minutes'] as int)
      };
    } catch (e) {
      /// En caso de error devuelve un mapa vacío
      return {};
    }
  }

  /// Actualiza la duración de un tipo de trabajo en Firestore.
  /// Solo el Admin puede llamar a este método.
  Future<void> updateDuration(String workType, int durationMinutes) async {
    await _firestore
        .collection('work_type_durations')
        .doc(workType)
        .update({'duration_minutes': durationMinutes});
  }
}