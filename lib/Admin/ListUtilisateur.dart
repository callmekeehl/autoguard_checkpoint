import 'package:autoguard_flutter/Constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListUtilisateur extends StatefulWidget {
  @override
  _ListUtilisateurState createState() => _ListUtilisateurState();
}

class _ListUtilisateurState extends State<ListUtilisateur> {
  List utilisateurs = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUtilisateurs();
  }

  Future<void> fetchUtilisateurs() async {
    final response = await http.get(
      Uri.parse('$url/api/utilisateurs'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        setState(() {
          utilisateurs = json.decode(response.body);
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
            'Erreur de chargement des utilisateurs: ${response.reasonPhrase}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Utilisateurs'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: utilisateurs.length,
                  itemBuilder: (context, index) {
                    final utilisateur = utilisateurs[index];
                    return ListTile(
                      title: Text(
                          '${utilisateur['prenom']} ${utilisateur['nom']}'),
                      subtitle: Text(utilisateur['email']),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditUtilisateur(utilisateur: utilisateur),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class EditUtilisateur extends StatefulWidget {
  final Map utilisateur;

  EditUtilisateur({required this.utilisateur});

  @override
  _EditUtilisateurState createState() => _EditUtilisateurState();
}

class _EditUtilisateurState extends State<EditUtilisateur> {
  late TextEditingController _prenomController;
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _adresseController;
  late TextEditingController _telephoneController;

  @override
  void initState() {
    super.initState();
    _prenomController =
        TextEditingController(text: widget.utilisateur['prenom']);
    _nomController = TextEditingController(text: widget.utilisateur['nom']);
    _emailController = TextEditingController(text: widget.utilisateur['email']);
    _adresseController =
        TextEditingController(text: widget.utilisateur['adresse']);
    _telephoneController =
        TextEditingController(text: widget.utilisateur['telephone']);
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> updateUtilisateur() async {
    final response = await http.put(
      Uri.parse('$url/api/utilisateurs/${widget.utilisateur['utilisateurId']}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prenom': _prenomController.text,
        'nom': _nomController.text,
        'email': _emailController.text,
        'adresse': _adresseController.text,
        'telephone': _telephoneController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Informations mise à jour'),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context,
          true); // Retourne à la liste des utilisateurs après la mise à jour
    } else {
      // Gérer les erreurs
      print(
          'Updating utilisateur with ID: ${widget.utilisateur['utilisateurId']}');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Erreur lors de la mise à jour de l\'utilisateur.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Utilisateur'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _prenomController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _adresseController,
              decoration: InputDecoration(labelText: 'Adresse'),
            ),
            TextFormField(
              controller: _telephoneController,
              decoration: InputDecoration(labelText: 'Téléphone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateUtilisateur();
              },
              child: Text(
                'Enregistrer',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
