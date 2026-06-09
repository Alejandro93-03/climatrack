import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/login/login_page.dart';
import '../pages/admin_home/admin_home.dart';
import '../pages/installer_home/installer_home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Obtener UID del admin desde admin/main
  Future<bool> _isAdmin(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('admin')
        .doc('main')
        .get();

    final adminUid = snap.data()?['uid'];
    return uid == adminUid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Esperando autenticación
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No autenticado → Login
        if (!authSnapshot.hasData) {
          return const LoginPage();
        }

        final user = authSnapshot.data!;
        final uid = user.uid;

        // Determinar si es admin o técnico
        return FutureBuilder<bool>(
          future: _isAdmin(uid),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isAdmin = adminSnapshot.data ?? false;

            // Redirección según UID
            return isAdmin ? const AdminHome() : const InstallerHome();
          },
        );
      },
    );
  }
}
