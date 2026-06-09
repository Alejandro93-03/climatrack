import 'package:flutter/material.dart' hide Material;
import 'package:provider/provider.dart';

import '../../../models/material.dart';
import '../../../providers/material_provider.dart';
import '../../../providers/work_order_provider.dart';

class MaterialSelectorModal extends StatefulWidget {
  final String workOrderId;

  const MaterialSelectorModal({super.key, required this.workOrderId});

  @override
  State<MaterialSelectorModal> createState() => _MaterialSelectorModalState();
}

class _MaterialSelectorModalState extends State<MaterialSelectorModal> {
  Material? selectedMaterial;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final materials = context.watch<MaterialProvider>().materials;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Añadir material",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // LISTA DE MATERIALES
          Expanded(
            child: ListView.builder(
              itemCount: materials.length,
              itemBuilder: (_, index) {
                final m = materials[index];
                final isSelected = selectedMaterial?.id == m.id;

                return ListTile(
                  title: Text(m.name),
                  subtitle: Text(
                    "${m.reference} • ${m.unitPrice.toStringAsFixed(2)} €",
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedMaterial = m;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // SELECTOR DE CANTIDAD
          if (selectedMaterial != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cantidad:", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () => setState(() => quantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 16),

          // BOTÓN AÑADIR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedMaterial == null
                  ? null
                  : () async {
                      await context
                          .read<WorkOrderProvider>()
                          .addMaterialToWorkOrder(
                            widget.workOrderId,
                            selectedMaterial!,
                            quantity,
                          );

                      Navigator.pop(context);
                    },
              child: const Text("Añadir al parte"),
            ),
          ),
        ],
      ),
    );
  }
}
