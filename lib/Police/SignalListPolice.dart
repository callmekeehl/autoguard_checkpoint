import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoguard_flutter/Constant.dart';

class SignalList extends StatefulWidget {
  @override
  _SignalListState createState() => _SignalListState();
}

class _SignalListState extends State<SignalList> {
  List<dynamic> declarations = [];
  List<dynamic> filteredDeclarations = []; // Liste filtrée
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController =
      TextEditingController(); // Contrôleur de recherche

  @override
  void initState() {
    super.initState();
    _fetchDeclarations();
  }

  Future<void> _fetchDeclarations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? token = prefs.getString('authToken');

    if (userId == null || token == null) {
      setState(() {
        errorMessage = 'Erreur : Utilisateur non identifié.';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$url/api/declarations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          declarations = json.decode(response.body);
          filteredDeclarations =
              declarations; // Initialiser avec toutes les déclarations
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur : Impossible de récupérer les déclarations.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de chargement des déclarations : $e';
        isLoading = false;
      });
    }
  }

  void _filterDeclarations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDeclarations =
            declarations; // Réinitialiser si le champ est vide
      } else {
        filteredDeclarations = declarations.where((declaration) {
          final marque = declaration['marque']?.toLowerCase() ?? '';
          final modele = declaration['modele']?.toLowerCase() ?? '';
          final queryLower = query.toLowerCase();
          return marque.contains(queryLower) || modele.contains(queryLower);
        }).toList();
      }
    });
  }

  void _showDeclarationDetails(
      BuildContext context, Map<String, dynamic> declaration) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Détails de la Déclaration"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "Propriétaire : ${declaration['prenomProprio']} ${declaration['nomProprio']}"),
                Text("Téléphone : ${declaration['telephoneProprio']}"),
                Text("Marque : ${declaration['marque']}"),
                Text("Modèle : ${declaration['modele']}"),
                Text("Numéro de Châssis : ${declaration['numChassis']}"),
                Text("Numéro de Plaque : ${declaration['numPlaque']}"),
                Text("Lieu (Longitude) : ${declaration['lieuLong']}"),
                Text("Lieu (Latitude) : ${declaration['lieuLat']}"),
                Text("Date et Heure : ${declaration['dateHeure']}"),
                Text("Statut : ${declaration['statut']}"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Fermer"),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: Text(
          'Liste des Déclarations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade400,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Rechercher une déclaration',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged:
                        _filterDeclarations, // Appeler la fonction de filtrage
                  ),
                ),
                Expanded(
                  child: errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : ListView.builder(
                          itemCount: filteredDeclarations.length,
                          itemBuilder: (context, index) {
                            final declaration = filteredDeclarations[index];
                            return ListTile(
                              title: Text(
                                '${declaration['marque']} ${declaration['modele']}',
                              ),
                              subtitle: Text(
                                  'Déclaré le: ${declaration['dateHeure']}\nPropriétaire: ${declaration['prenomProprio']} ${declaration['nomProprio']}'),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                _showDeclarationDetails(context, declaration);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
