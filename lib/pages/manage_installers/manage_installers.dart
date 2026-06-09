import 'package:clima_track/pages/manage_installers/add_installers_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';

class ManageRolesPage extends StatefulWidget {
  const ManageRolesPage({super.key});

  @override
  State<ManageRolesPage> createState() => _ManageRolesPageState();
}

class _ManageRolesPageState extends State<ManageRolesPage> {
  final searchController = TextEditingController();
  String sortMode = "email_asc";

  bool showArrow = false;
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

  bool _canEditUser(String uid) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isAdmin = currentUid == adminUid;
    final isSelf = uid == currentUid;

    return isAdmin && !isSelf;
  }

  // ───────────────────────────────────────────────
  // DIÁLOGO PARA EDITAR NOMBRE + APELLIDOS
  // ───────────────────────────────────────────────
  void _editNameDialog(String uid, String currentName, String currentLastname) {
    final nameController = TextEditingController(text: currentName);
    final lastnameController = TextEditingController(text: currentLastname);

    showDialog(
      context: context,
      builder: (context) {
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
                Text("Editar técnico", style: AppTextStyles.h2),
                const SizedBox(height: 20),

                AppInputs.primary(
                  placeholder: "Nombre",
                  controller: nameController,
                  width: double.infinity,
                ),
                const SizedBox(height: 16),

                AppInputs.primary(
                  placeholder: "Apellidos",
                  controller: lastnameController,
                  width: double.infinity,
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButtons.outlinedPrimary(
                      text: "Cancelar",
                      width: 120,
                      onPressed: () => Navigator.pop(context),
                    ),
                    AppButtons.primary(
                      text: "Guardar",
                      width: 120,
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({
                              "name": nameController.text.trim(),
                              "lastname": lastnameController.text.trim(),
                            });

                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // CONFIRMAR BORRADO
  // ───────────────────────────────────────────────
  void _confirmDeleteUser(String uid, String email) {
    showDialog(
      context: context,
      builder: (context) {
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
                Text("Eliminar usuario", style: AppTextStyles.h2),
                const SizedBox(height: 16),

                Text(
                  "¿Seguro que quieres eliminar a:\n$email?",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1,
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButtons.outlinedPrimary(
                      text: "Cancelar",
                      width: 120,
                      onPressed: () => Navigator.pop(context),
                    ),
                    AppButtons.primary(
                      text: "Eliminar",
                      width: 120,
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .delete();

                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // ORDENAR
  // ───────────────────────────────────────────────
  Widget _buildSortOption(String label, String value, Function modalSetState) {
    return RadioListTile(
      title: Text(label, style: AppTextStyles.body1),
      value: value,
      groupValue: sortMode,
      activeColor: AppColors.primary,
      onChanged: (v) {
        modalSetState(() => sortMode = v.toString());
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  void _openSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Ordenar técnicos", style: AppTextStyles.h2),
                  const SizedBox(height: 20),

                  _buildSortOption("Email A → Z", "email_asc", modalSetState),
                  _buildSortOption("Email Z → A", "email_desc", modalSetState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // UI PRINCIPAL
  // ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (adminUid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isAdmin = currentUid == adminUid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Gestión de técnicos", style: AppTextStyles.h2w),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // BUSCADOR + BOTÓN ORDENAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppInputs.primary(
                    placeholder: "Buscar técnico...",
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
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 BOTÓN AÑADIR TÉCNICO (ESTILO AddClientPage)
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButtons.primary(
                text: "Añadir técnico",
                width: double.infinity,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddInstallerPage()),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // LISTA DE TÉCNICOS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final query = searchController.text.toLowerCase();

                List filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data["name"] ?? "").toLowerCase();
                  final lastname = (data["lastname"] ?? "").toLowerCase();
                  final email = (data["email"] ?? "").toLowerCase();
                  final fullName = "$name $lastname".trim();

                  return query.isEmpty ||
                      name.contains(query) ||
                      lastname.contains(query) ||
                      fullName.contains(query) ||
                      email.contains(query);
                }).toList();

                filtered.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  final emailA = (dataA["email"] ?? "")
                      .toString()
                      .toLowerCase();
                  final emailB = (dataB["email"] ?? "")
                      .toString()
                      .toLowerCase();

                  return sortMode == "email_asc"
                      ? emailA.compareTo(emailB)
                      : emailB.compareTo(emailA);
                });

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 40,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final data = user.data() as Map<String, dynamic>;
                    final uid = user.id;

                    final name = data["name"] ?? "";
                    final lastname = data["lastname"] ?? "";
                    final email = data["email"] ?? "";

                    final editable = _canEditUser(uid);

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "$name $lastname".trim().isEmpty
                                              ? "(Sin nombre)"
                                              : "$name $lastname",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.body1.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: editable
                                                ? AppColors.black
                                                : AppColors.grey.withOpacity(
                                                    0.35,
                                                  ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: editable
                                                ? () => _editNameDialog(
                                                    uid,
                                                    name,
                                                    lastname,
                                                  )
                                                : null,
                                            child: Icon(
                                              Icons.edit,
                                              size: 22,
                                              color: editable
                                                  ? AppColors.primary
                                                  : AppColors.grey.withOpacity(
                                                      0.3,
                                                    ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          if (isAdmin)
                                            GestureDetector(
                                              onTap: () => _confirmDeleteUser(
                                                uid,
                                                email,
                                              ),
                                              child: Icon(
                                                Icons.delete,
                                                size: 24,
                                                color: Colors.red.withOpacity(
                                                  0.85,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    email,
                                    style: AppTextStyles.body2.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
