import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Servicio que gestiona las notificaciones push de Firebase Cloud Messaging.
/// Se encarga de solicitar permisos, obtener el token y manejar los mensajes.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Inicializa el servicio de notificaciones.
  /// Solicita permisos al usuario y configura los listeners.
  static Future<void> initialize() async {
    /// Solicitar permisos al usuario
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permisos de notificación: ${settings.authorizationStatus}');

    /// Obtener el token del dispositivo para enviar notificaciones
    String? token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    /// Escuchar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Mensaje recibido en primer plano: ${message.notification?.title}');
    });

    /// Escuchar cuando el usuario toca una notificación con la app en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notificación tocada: ${message.notification?.title}');
    });
  }

  /// Obtiene el token FCM del dispositivo actual.
  /// Este token se usa para enviar notificaciones a un dispositivo específico.
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Suscribe al dispositivo a un topic.
  /// Por ejemplo: 'instalador_UID' para recibir notificaciones de ese instalador.
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Suscrito al topic: $topic');
  }

  /// Cancela la suscripción a un topic.
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Desuscrito del topic: $topic');
  }
}