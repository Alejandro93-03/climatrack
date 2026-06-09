import 'package:flutter/material.dart';
import '../repository/work_type_duration_repository.dart';

/// Provider que gestiona el estado de las duraciones de los tipos de trabajo.
/// Sigue el patrón Provider + Repository definido en la guía del proyecto.
class WorkTypeDurationProvider extends ChangeNotifier {
  final WorkTypeDurationRepository _repository = WorkTypeDurationRepository();

  /// Mapa de tipos de trabajo con sus duraciones en minutos
  Map<String, int> _durations = {};

  /// Indica si hay una operación en curso
  bool _isLoading = false;

  /// Mensaje de error si algo falla
  String? _errorMessage;

  Map<String, int> get durations => _durations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga todas las duraciones desde Firestore
  Future<void> loadDurations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _durations = await _repository.getAllDurations();
    } catch (e) {
      _errorMessage = 'Error al cargar las duraciones: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Devuelve la duración estimada en minutos para un tipo de trabajo.
  /// Si no está cargado todavía, lo consulta directamente en Firestore.
  Future<int> getDurationForType(String workType) async {
    if (_durations.containsKey(workType)) {
      return _durations[workType]!;
    }
    return await _repository.getDurationForType(workType);
  }

  /// Actualiza la duración de un tipo de trabajo.
  /// Solo el Admin puede llamar a este método.
  Future<void> updateDuration(String workType, int durationMinutes) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateDuration(workType, durationMinutes);
      _durations[workType] = durationMinutes;
    } catch (e) {
      _errorMessage = 'Error al actualizar la duración: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}