import 'package:clima_track/pages/create_work_orders/create_work_order_page.dart';
import 'package:clima_track/pages/profile_page/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_colors.dart';
import '../../core/app_textstyles.dart';
import '../../widgets/app_buttons.dart';
import '../manage_installers/manage_installers.dart';
import '../manage_clients/manage_clients_page.dart';
import 'work_order_card.dart';
import 'work_order_detail_page.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

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
  bool filtrarHoy = true;

  final Map<String, String> workTypeLabels = {
    "gas_revision": "Revisión del gas",
    "ac_installation": "Instalación de aire acondicionado",
    "ac_repair": "Reparación de aire acondicionado",
    "maintenance": "Mantenimiento",
  };

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
      final data = snap.data()!;
      final name = data["name"] ?? "";

      setState(() {
        userName = name;
      });
    }
  }

  /// STREAM dinámico según filtro
  Stream<QuerySnapshot> _getWorkOrdersStream() {
    final collection = FirebaseFirestore.instance.collection("work_orders");

    if (filtrarHoy) {
      final hoy = DateTime.now();
      final inicio = DateTime(hoy.year, hoy.month, hoy.day, 0, 0);
      final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59);

      return collection
          .where(
            "scheduled_date",
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
          )
          .where("scheduled_date", isLessThanOrEqualTo: Timestamp.fromDate(fin))
          .orderBy("scheduled_date")
          .snapshots();
    }

    return collection.orderBy("scheduled_date").snapshots();
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Partes del día", style: AppTextStyles.h2),
                AppButtons.outlinedPrimary(
                  text: filtrarHoy ? "Ver todas" : "Ver solo hoy",
                  onPressed: () {
                    setState(() => filtrarHoy = !filtrarHoy);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: _getWorkOrdersStream(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;

                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        filtrarHoy
                            ? "No hay partes para hoy"
                            : "No hay órdenes de trabajo",
                        style: AppTextStyles.body1,
                      ),
                    ),
                  );
                }

                return Column(
                  children: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;

                    return WorkOrderCard(
                      orderId: d.id,
                      orderCode: data["number"] ?? "Sin número",
                      clientId: data["client_id"],
                      type: data["type"] ?? "",
                      status: data["status"] ?? "pendiente",
                      scheduledDate: (data["scheduled_date"] as Timestamp?)
                          ?.toDate(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkOrderDetailPage(orderId: d.id),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            AppButtons.primary(
              text: "Crear orden de trabajo",
              width: double.infinity,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateWorkOrderPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            AppButtons.outlinedPrimary(
              text: "Gestión de técnicos",
              width: double.infinity,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageRolesPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            AppButtons.outlinedPrimary(
              text: "Gestión de clientes",
              width: double.infinity,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageClientsPage()),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
