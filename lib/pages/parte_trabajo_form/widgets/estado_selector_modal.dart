import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_textstyles.dart';
import '../../../providers/work_order_provider.dart';

class EstadoSelectorModal extends StatelessWidget {
  final String workOrderId;
  final String currentStatus;

  const EstadoSelectorModal({
    super.key,
    required this.workOrderId,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final estados = _estadosPermitidos(currentStatus);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text("Cambiar estado", style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            "Estado actual: ${currentStatus.toUpperCase()}",
            style: AppTextStyles.body1.copyWith(color: AppColors.greyDark),
          ),
          const SizedBox(height: 20),

          ...estados.map((estado) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await context.read<WorkOrderProvider>().updateStatus(
                      workOrderId,
                      estado,
                      FirebaseAuth.instance.currentUser!.uid,
                    );
                    Navigator.pop(context, estado);
                  },
                  child: Text(
                    estado.replaceAll('_', ' ').toUpperCase(),
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                "Cancelar",
                style: AppTextStyles.body1.copyWith(color: AppColors.greyDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _estadosPermitidos(String actual) {
    switch (actual) {
      case "pendiente":
        return ["en_ruta"];
      case "en_ruta":
        return ["en_curso"];
      case "en_curso":
        return ["pendiente_firma"];
      case "pendiente_firma":
        return ["completado"];
      case "completado":
        return ["facturado"];
      default:
        return [];
    }
  }
}
