import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant.dart';

class ListNotification extends StatefulWidget {
  @override
  _ListNotificationState createState() => _ListNotificationState();
}

class _ListNotificationState extends State<ListNotification> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? token = prefs.getString('authToken');

    if (userId == null) {
      setState(() {
        errorMessage = 'Erreur : Utilisateur non identifié.';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$url/api/notifications/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur de chargement des notifications';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de chargement des notifications: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    try {
      await http.put(
        Uri.parse('$url/api/notifications/$notificationId/mark-as-read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print("Erreur lors de la mise à jour de la notification : $e");
    }
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Détails de la notification"),
        content: Text(notification['message'] ?? 'Aucun détail disponible'),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );

    if (notification['lu'] == false) {
      setState(() {
        notification['lu'] = true;
      });
      _markAsRead(notification['notificationId']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Liste des Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade400,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    // Vérification des données nulles et transformation du booléen en icône
                    final bool estLue = notification['lu'] ?? false;
                    final String date =
                        notification['dateEnvoi'] ?? 'Date inconnue';
                    final String message =
                        notification['message'] ?? 'Message non disponible';

                    return ListTile(
                      leading: !estLue
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null, // Coche verte si non lue
                      title: Text(date),
                      subtitle: Text(message.substring(
                              0, message.length > 50 ? 50 : message.length) +
                          '...'),
                      onTap: () {
                        _showNotificationDetails(notification);
                      },
                    );
                  },
                ),
    );
  }
}
