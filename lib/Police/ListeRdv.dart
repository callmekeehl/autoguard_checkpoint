import 'package:autoguard_flutter/Constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListeRdv extends StatefulWidget {
  @override
  _ListeRdvState createState() => _ListeRdvState();
}

class _ListeRdvState extends State<ListeRdv> {
  List<dynamic> motifs = [];
  Map<int, Map<String, String>> utilisateurs =
      {}; // Map pour stocker les détails des utilisateurs
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMotifs();
  }

  Future<void> _loadMotifs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse('$url/api/motifs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        List<dynamic> fetchedMotifs = jsonDecode(response.body);
        setState(() {
          motifs = fetchedMotifs;
        });

        // Charger les détails des utilisateurs
        for (var motif in fetchedMotifs) {
          int utilisateurId = motif['utilisateurId'];
          if (!utilisateurs.containsKey(utilisateurId)) {
            await _loadUtilisateurDetails(utilisateurId);
          }
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Erreur de parsing des données JSON';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage =
            'Erreur de chargement des motifs: ${response.reasonPhrase}';
        isLoading = false;
      });
    }
  }

  Future<void> _loadUtilisateurDetails(int utilisateurId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final response = await http.get(
      Uri.parse('$url/api/utilisateurs/$utilisateurId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> utilisateurData = jsonDecode(response.body);
      setState(() {
        utilisateurs[utilisateurId] = {
          'nom': utilisateurData['nom'] ?? 'Inconnu',
          'prenom': utilisateurData['prenom'] ?? 'Inconnu',
        };
      });
    } else {
      setState(() {
        utilisateurs[utilisateurId] = {
          'nom': 'Erreur',
          'prenom': 'Erreur',
        };
      });
    }
  }

  Future<void> _accepterRdv(int motifId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    int? policeId = prefs.getInt('policeId');
    if (policeId == null) {
      // Erreur de récupération du policeId
      print('PoliceId null');
    }

    final response = await http.put(
      Uri.parse('$url/api/rdvs/accept/$motifId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'policeId': policeId,
        'message': 'Votre Rendez-vous a été confirmer avec succès',
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _loadMotifs(); // Recharger la liste
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rendez-vous accepté et notification envoyée.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'acceptation du rendez-vous.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejeterRdv(int motifId) async {
    TextEditingController raisonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Raison du rejet'),
          content: TextField(
            controller: raisonController,
            decoration:
                InputDecoration(hintText: "Saisissez la raison du rejet"),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Rejeter'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('authToken');

                final response = await http.put(
                  Uri.parse('$url/api/rdvs/reject/$motifId'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    'raison': raisonController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    _loadMotifs();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Rendez-vous rejeté et notification envoyée.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors du rejet du rendez-vous.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                Navigator.of(context).pop(); // Fermer le dialogue
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blue.shade400,
        title: Text(
          'Liste des demandes de rendez-vous',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: motifs.length,
                  itemBuilder: (context, index) {
                    final motif = motifs[index];
                    int utilisateurId = motif['utilisateurId'];
                    Map<String, String>? utilisateur =
                        utilisateurs[utilisateurId];

                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Utilisateur: ${utilisateur?['prenom'] ?? 'Inconnu'} ${utilisateur?['nom'] ?? 'Inconnu'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Motif: ${motif['motifDescription']}'),
                            SizedBox(height: 5),
                            Text(
                                'Date et Heure: ${motif['date'] ?? 'Non précisée'}'),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _accepterRdv(motif['motifId']);
                                  },
                                  child: Text('Accepter',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _rejeterRdv(motif['motifId']);
                                  },
                                  child: Text('Rejeter',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
