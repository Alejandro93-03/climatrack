import 'package:clima_track/models/material.dart';
import 'package:clima_track/repository/material_repository.dart';
import 'package:flutter/material.dart' hide Material;

// Encargado de exponer lista de materiales, estado de carga, métodos para selección de material
// Esto me da: catálogo actualizado en tiempo real y acceso desde cualquier widget con Provider
class MaterialProvider extends ChangeNotifier {
  final MaterialRepository _repo;
  List<Material> materials = [];

  MaterialProvider(this._repo) {
    _listenMaterials();
  }

  void _listenMaterials() {
    _repo.getMaterials().listen((data) {
      materials = data;
      notifyListeners();
    });
  }
}
