import 'package:clima_track/pages/agenda_dia/agenda_dia_page.dart';
import 'package:clima_track/pages/profile_page/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';

class InstallerHome extends StatelessWidget {
  const InstallerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (snap.exists) {
      setState(() {
        userName = snap.data()?["name"] ?? "Instalador";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = userName == null ? "Bienvenido..." : "Bienvenido, $userName";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(title, style: AppTextStyles.h2w),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),

      // ⭐⭐ NUEVO DISEÑO, RESPETANDO TU ESTRUCTURA ⭐⭐ (CLM-AESTHETIC)
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔧 Encabezado visual (nuevo)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.engineering,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Panel del Técnico",
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Accede a tu agenda diaria",
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.greyDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 🔵 Botón principal (tu botón original, sin tocar)
            AppButtons.primary(
              text: "Agenda del Día",
              width: 250,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgendaDiaPage()),
                );
              },
            ),

            const SizedBox(height: 40),

            // 🎨 Fondo decorativo suave
            Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.construction,
                size: 140,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
