import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un parte de trabajo en la colección work_orders de Firestore.
class WorkOrder {
  /// ID único del parte (generado por Firestore)
  final String id;

  /// Número correlativo del parte (ej: CLM-2026-001)
  final String number;

  /// Referencia al ID del cliente en la colección clients
  final String clientId;

  /// UID del técnico asignado (proporcionado por Firebase Auth)
  final String technicianId;

  /// Tipo de servicio.
  /// Valores: 'gas_revision' | 'ac_installation' | 'ac_repair' | 'maintenance'
  final String type;

  /// Estado actual del parte.
  /// Valores: 'pendiente' | 'en_ruta' | 'en_curso' | 'pendiente_firma' | 'completado' | 'nadie_en_casa' | 'facturado'
  final String status;

  /// Fecha y hora programada para realizar el trabajo
  final DateTime scheduledDate;

  /// Hora real de inicio del trabajo (null hasta que empieza)
  final DateTime? startedAt;

  /// Hora real de fin del trabajo (null hasta que termina)
  final DateTime? finishedAt;

  /// Lista de materiales usados: { material_id, name, quantity, unit_price, subtotal }
  final List<Map<String, dynamic>> materialsUsed;

  /// Coste de mano de obra en euros
  final double laborCost;

  /// Notas del técnico sobre el trabajo
  final String observations;

  /// URL de la firma del cliente en Firebase Storage (null hasta que se firma)
  final String? signatureUrl;

  /// URL del PDF generado en Firebase Storage (null hasta que se genera)
  final String? pdfUrl;

  WorkOrder({
    required this.id,
    required this.number,
    required this.clientId,
    required this.technicianId,
    required this.type,
    required this.status,
    required this.scheduledDate,
    this.startedAt,
    this.finishedAt,
    required this.materialsUsed,
    required this.laborCost,
    required this.observations,
    this.signatureUrl,
    this.pdfUrl,
  }) : assert(
         [
           'gas_revision',
           'ac_installation',
           'ac_repair',
           'maintenance',
         ].contains(type),
       ),
       assert(
         [
           'pendiente',
           'en_ruta',
           'en_curso',
           'pendiente_firma',
           'completado',
           'nadie_en_casa',
           'facturado',
         ].contains(status),
       );

  /// Crea un objeto WorkOrder a partir de un mapa de datos de Firestore
  factory WorkOrder.fromMap(Map<String, dynamic> map, String id) {
    return WorkOrder(
      id: id,
      number: map['number'],
      clientId: map['client_id'],
      technicianId: map['technician_id'],
      type: map['type'],
      status: map['status'],
      scheduledDate: (map['scheduled_date'] as Timestamp).toDate(),
      startedAt: map['started_at'] != null
          ? (map['started_at'] as Timestamp).toDate()
          : null,
      finishedAt: map['finished_at'] != null
          ? (map['finished_at'] as Timestamp).toDate()
          : null,
      materialsUsed: List<Map<String, dynamic>>.from(
        map['materials_used'] ?? [],
      ),
      laborCost: (map['labor_cost'] as num).toDouble(),
      observations: map['observations'] ?? '',
      signatureUrl: map['signature_url'],
      pdfUrl: map['pdf_url'],
    );
  }

  /// Convierte el objeto WorkOrder a un mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'client_id': clientId,
      'technician_id': technicianId,
      'type': type,
      'status': status,
      'scheduled_date': Timestamp.fromDate(scheduledDate),
      'started_at': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'finished_at': finishedAt != null
          ? Timestamp.fromDate(finishedAt!)
          : null,
      'materials_used': materialsUsed,
      'labor_cost': laborCost,
      'observations': observations,
      'signature_url': signatureUrl,
      'pdf_url': pdfUrl,
    };
  }

  /// Crea una copia del WorkOrder modificando solo los campos indicados.
  /// Útil para actualizar el estado sin recrear el objeto completo.
  WorkOrder copyWith({
    String? id,
    String? number,
    String? clientId,
    String? technicianId,
    String? type,
    String? status,
    DateTime? scheduledDate,
    DateTime? startedAt,
    DateTime? finishedAt,
    List<Map<String, dynamic>>? materialsUsed,
    double? laborCost,
    String? observations,
    String? signatureUrl,
    String? pdfUrl,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      number: number ?? this.number,
      clientId: clientId ?? this.clientId,
      technicianId: technicianId ?? this.technicianId,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      laborCost: laborCost ?? this.laborCost,
      observations: observations ?? this.observations,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }
}
