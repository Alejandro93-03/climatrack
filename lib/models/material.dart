/// Representa un material del catálogo en la colección `materials` de Firestore.
/// COINCIDE EXACTAMENTE CON LA ESTRUCTURA DE FIRESTORE SEGÚN GUÍA
class Material {
  /// ID único del material (generado por Firestore)
  final String id;

  /// Nombre del material (ej: 'Filtro AC Split Inverter')
  final String name;

  /// Referencia o código del fabricante
  final String reference;

  /// Precio unitario en euros sin IVA
  final double unitPrice;

  /// Unidad de medida. Valores: 'ud' | 'metro' | 'kg' | 'litro'
  final String unit;

  /// Categoría del material. Valores: 'gas' | 'ac' | 'general'
  final String category;

  /// Si el material está disponible en el catálogo o está descatalogado
  final bool isActive;

  Material({
    required this.id,
    required this.name,
    required this.reference,
    required this.unitPrice,
    required this.unit,
    required this.category,
    required this.isActive,
  }) : assert(['ud', 'metro', 'kg', 'litro'].contains(unit)),
       assert(['gas', 'ac', 'general'].contains(category));

  /// Crea un objeto Material a partir de un documento de Firestore
  factory Material.fromMap(Map<String, dynamic> map, String id) {
    return Material(
      id: id,
      name: map['name'],
      reference: map['reference'],
      unitPrice: (map['unit_price'] as num).toDouble(),
      unit: map['unit'],
      category: map['category'],
      isActive: map['is_active'],
    );
  }

  /// Convierte el objeto Material a un mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reference': reference,
      'unit_price': unitPrice,
      'unit': unit,
      'category': category,
      'is_active': isActive,
    };
  }
}
