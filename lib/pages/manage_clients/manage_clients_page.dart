import 'package:clima_track/pages/manage_clients/add_clients_page.dart';
import 'package:clima_track/pages/manage_clients/client_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';

class ManageClientsPage extends StatefulWidget {
  const ManageClientsPage({super.key});

  @override
  State<ManageClientsPage> createState() => _ManageClientsPageState();
}

class _ManageClientsPageState extends State<ManageClientsPage> {
  final searchController = TextEditingController();

  String sortMode = "name_asc";
  String? adminUid;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool get isAdmin {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    return currentUid == adminUid;
  }

  void _openSortOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomPadding + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ordenar clientes", style: AppTextStyles.h2),
              const SizedBox(height: 20),

              _buildSortOption("A → Z (Nombre)", "name_asc"),
              _buildSortOption("Z → A (Nombre)", "name_desc"),
              _buildSortOption("Instalaciones ↑", "inst_asc"),
              _buildSortOption("Instalaciones ↓", "inst_desc"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    return RadioListTile(
      title: Text(label, style: AppTextStyles.body1),
      value: value,
      groupValue: sortMode,
      activeColor: AppColors.primary,
      onChanged: (v) {
        setState(() => sortMode = v.toString());
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (adminUid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Gestión de clientes", style: AppTextStyles.h2w),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // BUSCADOR + BOTÓN ORDENAR
            Row(
              children: [
                Expanded(
                  child: AppInputs.primary(
                    placeholder: "Buscar cliente...",
                    controller: searchController,
                    width: double.infinity,
                    prefixIcon: Icons.search,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openSortOptions,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Icon(Icons.sort, color: AppColors.primary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // AÑADIR CLIENTE (solo admin)
            if (isAdmin)
              AppButtons.primary(
                text: "Añadir cliente",
                width: double.infinity,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddClientPage()),
                  );
                },
              ),

            if (isAdmin) const SizedBox(height: 20),

            // LISTA DE CLIENTES
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clients')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  final query = searchController.text.toLowerCase();

                  List filtered = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final name = (data["name"] ?? "").toString().toLowerCase();
                    final email = (data["email"] ?? "")
                        .toString()
                        .toLowerCase();
                    final address = (data["address"] ?? "")
                        .toString()
                        .toLowerCase();
                    final installations =
                        (data["installations"] as List?)?.length ?? 0;

                    if (query.isEmpty) return true;

                    return name.contains(query) ||
                        email.contains(query) ||
                        address.contains(query) ||
                        installations.toString().contains(query);
                  }).toList();

                  // ORDENACIÓN
                  filtered.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;

                    final nameA = (dataA["name"] ?? "")
                        .toString()
                        .toLowerCase();
                    final nameB = (dataB["name"] ?? "")
                        .toString()
                        .toLowerCase();

                    final instA =
                        (dataA["installations"] as List?)?.length ?? 0;
                    final instB =
                        (dataB["installations"] as List?)?.length ?? 0;

                    switch (sortMode) {
                      case "name_asc":
                        return nameA.compareTo(nameB);
                      case "name_desc":
                        return nameB.compareTo(nameA);
                      case "inst_asc":
                        return instA.compareTo(instB);
                      case "inst_desc":
                        return instB.compareTo(instA);
                      default:
                        return 0;
                    }
                  });

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No hay resultados",
                        style: AppTextStyles.body1,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final data =
                          filtered[index].data() as Map<String, dynamic>;

                      final name = data["name"] ?? "Sin nombre";
                      final email = data["email"] ?? "Sin email";
                      final address = data["address"] ?? "Sin dirección";
                      final installations =
                          (data["installations"] as List?)?.length ?? 0;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                          ),
                          title: Text(name, style: AppTextStyles.body1),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(email, style: AppTextStyles.body2),
                              Text(address, style: AppTextStyles.body2),
                              Text(
                                "Instalaciones: $installations",
                                style: AppTextStyles.body2,
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientDetailsPage(
                                  clientId: filtered[index].id,
                                  isAdmin: isAdmin, // PASAMOS PERMISO
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
