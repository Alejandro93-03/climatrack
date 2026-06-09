import 'package:clima_track/providers/agenda_provider.dart';
import 'package:clima_track/providers/material_provider.dart';
import 'package:clima_track/providers/work_order_provider.dart';
import 'package:clima_track/repository/material_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth.dart';
// Nuevos imports para la Tarea #36
import 'package:clima_track/providers/admin_calendar_provider.dart';
// Nuevos imports para la Tarea #78
import 'services/notification_service.dart';
import 'package:clima_track/providers/work_order_assignment_provider.dart';

// 🔥 Necesario para DatePicker en español
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      // Árbol de Providers
      providers: [
        ChangeNotifierProvider(
          create: (_) => MaterialProvider(MaterialRepository()),
        ),
        ChangeNotifierProvider(create: (_) => WorkOrderProvider()),
        ChangeNotifierProvider(create: (_) => AgendaProvider()),
        ChangeNotifierProvider(create: (_) => AdminCalendarProvider()),
        ChangeNotifierProvider(create: (_) => WorkOrderAssignmentProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClimaTrack',

      // Localización en español. Ayuda a que el calendario que sale al seleccionar fecha aparezca en castellano
      // y la semana inicie en lunes, no en domingo.
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const AuthGate(),
    );
  }
}
