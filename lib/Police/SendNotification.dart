import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour encoder les données en JSON
import '../Constant.dart';

class SendNotificationPage extends StatefulWidget {
  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, String>> utilisateurs =
      []; // Liste vide pour les utilisateurs
  String? _selectedUserId;
  String? _selectedUserToken;

  @override
  void initState() {
    super.initState();
    fetchUtilisateurs(); // Charger les utilisateurs dès le démarrage de la page
  }

  // Fonction pour récupérer la liste des utilisateurs depuis le backend
  Future<void> fetchUtilisateurs() async {
    try {
      final response = await http.get(Uri.parse('$url/api/utilisateurs'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          utilisateurs = data.map((user) {
            return {
              'id': user['utilisateurId']
                  .toString(), // Utiliser 'utilisateurId' comme clé
              'nom': '${user['nom']} ${user['prenom']}', // Nom complet
            };
          }).toList();
        });
      } else {
        print('Erreur de récupération des utilisateurs: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de récupération des utilisateurs')),
        );
      }
    } catch (e) {
      print('Erreur lors de la requête: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la requête')),
      );
    }
  }

  // Fonction pour récupérer le token FCM de l'utilisateur sélectionné
  Future<void> fetchFCMToken(String utilisateurId) async {
    try {
      final response =
          await http.get(Uri.parse('$url/api/getFCMToken/$utilisateurId'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _selectedUserToken = data['fcmToken']; // Enregistrer le token FCM
        });
        print('Token FCM récupéré: $_selectedUserToken');
      } else {
        print('Erreur de récupération du token FCM: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de récupération du token FCM')),
        );
      }
    } catch (e) {
      print('Erreur lors de la requête pour obtenir le token FCM: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la requête pour le token FCM')),
      );
    }
  }

  // Fonction pour envoyer la notification
  Future<void> sendNotification(String titre, String message) async {
    if (_selectedUserToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token FCM introuvable pour cet utilisateur')),
      );
      return;
    }

    try {
      final Map<String, dynamic> data = {
        'utilisateurId': _selectedUserId, // ID de l'utilisateur sélectionné
        'title': titre,
        'message': message,
      };

      final response = await http.post(
        Uri.parse('$url/api/sendNotification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data), // Encode les données en JSON
      );

      if (response.statusCode == 200) {
        print('Notification envoyée avec succès');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification envoyée avec succès')));
      } else {
        print('Erreur : ${response.body}');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : ${response.body}')));
      }
    } catch (e) {
      print('Erreur d\'envoi : $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur d\'envoi : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Envoyer une notification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Menu déroulant pour sélectionner l'utilisateur
            utilisateurs.isEmpty
                ? CircularProgressIndicator() // Affiche un indicateur de chargement si les utilisateurs ne sont pas encore récupérés
                : DropdownButton<String>(
                    value: _selectedUserId,
                    hint: Text('Sélectionner un utilisateur'),
                    items: utilisateurs.map((utilisateur) {
                      return DropdownMenuItem<String>(
                        value: utilisateur['id'],
                        child: Text(
                            utilisateur['nom']!), // Affiche le nom et prénom
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUserId = value;
                        _selectedUserToken = null; // Réinitialiser le token
                      });
                      if (value != null) {
                        fetchFCMToken(value); // Charger le token FCM
                      }
                    },
                  ),
            TextField(
              controller: _titreController,
              decoration:
                  InputDecoration(labelText: "Titre de la notification"),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: "Message"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final titre = _titreController.text.trim();
                final message = _messageController.text.trim();

                if (_selectedUserId != null &&
                    titre.isNotEmpty &&
                    message.isNotEmpty) {
                  sendNotification(titre, message);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                }
              },
              child: Text("Envoyer la notification"),
            ),
          ],
        ),
      ),
    );
  }
}
