import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_calendar_provider.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colores corporativos Zaitec
    const Color acBlue = Color(0xFF005C97);
    const Color industrialWhite = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: industrialWhite,
      appBar: AppBar(
        title: const Text(
          'Gestión de Agenda - Admin',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: acBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Instaladores Disponibles",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // COLUMNA TÉCNICO A (ZONA DE SOLTAR)
                  _buildTechnicianColumn(context, "Técnico: Roberto"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianColumn(BuildContext context, String techName) {
    return Expanded(
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          // LLAMADA AL PROVIDER PARA PERSISTIR EN FIRESTORE
          context.read<AdminCalendarProvider>().reorderWorkOrder(
            details.data, // El ID de la orden
            DateTime.now(), // La nueva fecha/hora
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Trabajo reasignado a $techName")),
          );
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    techName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                // TARJETA ARRASTRABLE (Draggable)
                Draggable<String>(
                  data: "ORDEN-XYZ-789", // Aquí iría el ID real del documento
                  feedback: const Material(
                    child: Card(
                      color: Color(0xFF005C97),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Moviendo...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: _cardContenido(),
                  ),
                  child: _cardContenido(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cardContenido() {
    return const Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: Color(0xFF005C97)),
        title: Text("Reparación AC"),
        subtitle: Text("Cliente: Hotel Central"),
      ),
    );
  }
}
