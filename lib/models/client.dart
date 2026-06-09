/// Representa un cliente en la colección clients de Firestore.
class Client {
  
  /// ID único del cliente (generado por Firestore)
  final String? id;

  /// Nombre completo del cliente
  final String name;

  /// Dirección completa del domicilio
  final String address;

  /// Teléfono de contacto (String para preservar ceros iniciales)
  final String phone;

  /// Email para recibir facturas
  final String email;

  /// Lista de equipos instalados en el domicilio.
  /// Cada equipo tiene: type, brand, model, install_date, last_service_date, warranty_expiry
  final List<Map<String, dynamic>> installations;

  Client({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.installations,
  });

  /// Crea un objeto Client a partir de un mapa de datos de Firestore
  factory Client.fromMap(Map<String, dynamic> map, String id) {
    return Client(
      id: id,
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      installations: List<Map<String, dynamic>>.from(map['installations'] ?? []),
    );
  }

  /// Convierte el objeto Client a un mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'installations': installations,
    };
  }
}
