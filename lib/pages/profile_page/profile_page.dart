import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_inputs.dart';
import '../login/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Mi perfil", style: AppTextStyles.h2w),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name = data["name"] ?? "";
          final lastname = data["lastname"] ?? "";
          final fullName = "$name $lastname".trim();

          final email = data["email"] ?? "Sin email";

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("admin")
                .doc("main")
                .get(),
            builder: (context, adminSnap) {
              if (!adminSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final adminUid = adminSnap.data!.get("uid");
              final isAdmin = uid == adminUid;
              final roleLabel = isAdmin ? "Administrador" : "Instalador";

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOMBRE COMPLETO + ICONO EDITAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Nombre completo", style: AppTextStyles.body2),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () {
                            _showEditNameDialog(
                              context: context,
                              currentName: name,
                              currentLastname: lastname,
                              uid: uid,
                            );
                          },
                        ),
                      ],
                    ),
                    Text(
                      fullName.isEmpty ? "Sin nombre" : fullName,
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // EMAIL
                    Text("Email", style: AppTextStyles.body2),
                    Text(
                      email,
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ROL (ADMIN O INSTALADOR)
                    Text("Rol", style: AppTextStyles.body2),
                    Text(
                      roleLabel,
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // CERRAR SESIÓN
                    AppButtons.primary(
                      text: "Cerrar sesión",
                      width: double.infinity,
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (_) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔥 DIÁLOGO PARA EDITAR NOMBRE Y APELLIDOS
  // -------------------------------------------------------------
  void _showEditNameDialog({
    required BuildContext context,
    required String currentName,
    required String currentLastname,
    required String uid,
  }) {
    final nameController = TextEditingController(text: currentName);
    final lastnameController = TextEditingController(text: currentLastname);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text("Editar nombre", style: AppTextStyles.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInputs.primary(
                placeholder: "Nombre",
                controller: nameController,
                width: double.infinity,
              ),
              const SizedBox(height: 20),
              AppInputs.primary(
                placeholder: "Apellidos",
                controller: lastnameController,
                width: double.infinity,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar", style: AppTextStyles.body1),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Guardar", style: AppTextStyles.body1),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                      "name": nameController.text.trim(),
                      "lastname": lastnameController.text.trim(),
                    });

                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
