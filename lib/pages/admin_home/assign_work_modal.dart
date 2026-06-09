import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';

class AssignWorkModal extends StatefulWidget {
  final String orderId;

  const AssignWorkModal({super.key, required this.orderId});

  @override
  State<AssignWorkModal> createState() => _AssignWorkModalState();
}

class _AssignWorkModalState extends State<AssignWorkModal> {
  String? selectedTechnicianId;
  String? selectedTechnicianName;
  String? adminUid;

  @override
  void initState() {
    super.initState();
    _loadAdminUid();
  }

  Future<void> _loadAdminUid() async {
    final snap = await FirebaseFirestore.instance
        .collection('admin')
        .doc('main')
        .get();

    setState(() {
      adminUid = snap.data()?['uid'];
    });
  }

  void _openTechnicianSelector(List<QueryDocumentSnapshot> docs) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Seleccionar técnico", style: AppTextStyles.h2),
                const SizedBox(height: 20),

                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final name = "${d["name"]} ${d["lastname"]}";

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTechnicianId = docs[i].id;
                            selectedTechnicianName = name;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 10,
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(name, style: AppTextStyles.body1),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                AppButtons.outlinedPrimary(
                  text: "Cerrar",
                  width: double.infinity,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (adminUid == null) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Builder(
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Asignar técnico", style: AppTextStyles.h2),
                const SizedBox(height: 20),

                // 🔥 SELECTOR INDUSTRIAL
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data!.docs.where((doc) {
                      return doc.id != adminUid;
                    }).toList();

                    if (docs.isEmpty) {
                      return Text(
                        "No hay técnicos disponibles",
                        style: AppTextStyles.body1,
                      );
                    }

                    return GestureDetector(
                      onTap: () => _openTechnicianSelector(docs),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyLight),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedTechnicianName ??
                                  "Seleccionar técnico...",
                              style: AppTextStyles.body1,
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButtons.outlinedPrimary(
                      text: "Cancelar",
                      width: 120,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    AppButtons.primary(
                      text: "Asignar",
                      width: 120,
                      onPressed: () async {
                        if (selectedTechnicianId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Selecciona un técnico"),
                            ),
                          );
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection("work_orders")
                            .doc(widget.orderId)
                            .update({"technician_id": selectedTechnicianId});

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pop(context, true);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
