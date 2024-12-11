import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class FCMService {
  // Instance de FirebaseMessaging
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Instance pour les notifications locales
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Cette méthode initialise Firebase et la messagerie FCM
  static Future<void> initializeFCM() async {
    // Initialisation de Firebase
    await Firebase.initializeApp();

    // Configurez les notifications locales
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Demander la permission pour recevoir des notifications sur iOS
    await _firebaseMessaging.requestPermission();

    // Récupérer le token FCM de l'appareil
    String? token = await _firebaseMessaging.getToken();
    print("Token FCM: $token");

    // Vous pouvez envoyer ce token au backend pour l'associer à un utilisateur
    // ou l'enregistrer localement pour envoyer des notifications ultérieurement

    // Configurer les callbacks pour les notifications
    _configureForegroundMessageHandler();
    _configureBackgroundMessageHandler();
  }

  // Gérer les notifications en avant-plan (quand l'application est ouverte)
  static void _configureForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message reçu en avant-plan: ${message.notification?.title}");
      // Affichez une notification locale lorsque l'app est en avant-plan
      _showNotification(message);
    });
  }

  // Gérer les notifications en arrière-plan (quand l'application est en arrière-plan ou fermée)
  static Future<void> _configureBackgroundMessageHandler() async {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  // Gestionnaire de messages en arrière-plan
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print("Message reçu en arrière-plan: ${message.notification?.title}");
    // Affichez une notification locale
    _showNotification(message);
  }

  // Afficher une notification locale (en avant-plan ou en arrière-plan)
  static Future<void> _showNotification(RemoteMessage message) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id', // Remplacez par l'ID de votre chaîne
        'your_channel_name', // Remplacez par le nom de votre chaîne
        channelDescription: 'Your channel description',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    // Affichez la notification locale avec le titre et le corps
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // Cette méthode permet d'envoyer une notification via l'API backend qui utilise FCM
  static Future<void> sendNotification({
    required String token,
    required String title,
    required String message,
  }) async {
    try {
      // Endpoint de votre backend pour envoyer la notification
      const String backendUrl =
          'http://votre-backend-url/api/sendNotification'; // Remplacez par l'URL de votre backend

      // Corps de la requête
      final Map<String, dynamic> data = {
        'token': token, // Le token FCM de l'utilisateur cible
        'title': title,
        'message': message,
      };

      // Envoi de la requête POST à votre backend
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data), // Encodez les données en JSON
      );

      if (response.statusCode == 200) {
        print('Notification envoyée avec succès');
      } else {
        print('Erreur : ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification : $e');
    }
  }
}
