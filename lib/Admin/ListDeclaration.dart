import 'package:flutter/material.dart';
import 'package:autoguard_flutter/Constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListDeclaration extends StatefulWidget {
  @override
  _ListDeclarationState createState() => _ListDeclarationState();
}

class _ListDeclarationState extends State<ListDeclaration> {
  List declarations = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDeclarations();
  }

  Future<void> fetchDeclarations() async {
    final response = await http.get(
      Uri.parse('$url/api/declarations'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        setState(() {
          declarations = json.decode(response.body);
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
            'Erreur de chargement des Déclarations: ${response.reasonPhrase}';
        isLoading = false;
      });
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
          'Liste des Déclarations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade400,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: declarations.length,
                  itemBuilder: (context, index) {
                    final declaration = declarations[index];
                    return ListTile(
                      title: Text(
                          '${declaration['prenomProprio']} ${declaration['nomProprio']}'),
                      subtitle: Text(declaration['telephoneProprio']),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditDeclaration(declaration: declaration),
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

class EditDeclaration extends StatefulWidget {
  final Map declaration;

  EditDeclaration({required this.declaration});

  @override
  _EditDeclarationState createState() => _EditDeclarationState();
}

class _EditDeclarationState extends State<EditDeclaration> {
  late TextEditingController _prenomProprioController;
  late TextEditingController _nomProprioController;
  late TextEditingController _telephoneProprioController;
  late TextEditingController _lieuLongController;
  late TextEditingController _lieuLatController;
  late TextEditingController _numChassisController;
  late TextEditingController _numPlaqueController;
  late TextEditingController _marqueController;
  late TextEditingController _modeleController;

  @override
  void initState() {
    super.initState();
    _prenomProprioController =
        TextEditingController(text: widget.declaration['prenomProprio']);
    _nomProprioController =
        TextEditingController(text: widget.declaration['nomProprio']);
    _telephoneProprioController =
        TextEditingController(text: widget.declaration['telephoneProprio']);
    _lieuLongController =
        TextEditingController(text: widget.declaration['lieuLong']);
    _lieuLatController =
        TextEditingController(text: widget.declaration['lieuLat']);
    _numChassisController =
        TextEditingController(text: widget.declaration['numChassis']);
    _numPlaqueController =
        TextEditingController(text: widget.declaration['numPlaque']);
    _marqueController =
        TextEditingController(text: widget.declaration['marque']);
    _modeleController =
        TextEditingController(text: widget.declaration['modele']);
  }

  @override
  void dispose() {
    _prenomProprioController.dispose();
    _nomProprioController.dispose();
    _telephoneProprioController.dispose();
    _lieuLongController.dispose();
    _lieuLatController.dispose();
    _numChassisController.dispose();
    _numPlaqueController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();

    super.dispose();
  }

  Future<void> updateDeclaration() async {
    final response = await http.put(
      Uri.parse('$url/api/declarations/${widget.declaration['declarationId']}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'utilisateurId': widget.declaration['utilisateurId'],
        'prenomProprio': _prenomProprioController.text,
        'nomProprio': _nomProprioController.text,
        'telephoneProprio': _telephoneProprioController.text,
        'lieuLong': _lieuLongController.text,
        'lieuLat': _lieuLatController.text,
        'numChassis': _numChassisController.text,
        'numPlaque': _numPlaqueController.text,
        'marque': _marqueController.text,
        'modele': _modeleController.text
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Informations mise à jour'),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context,
          true); // Retourne à la liste des déclarations après la mise à jour
    } else {
      // Gérer les erreurs
      print(
          'Updating declaration with ID: ${widget.declaration['declarationId']}');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Erreur lors de la mise à jour de la déclaration.'),
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
        title: Text('Modifier Déclaration'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _prenomProprioController,
              decoration: InputDecoration(labelText: 'Prénom Propriétaire'),
            ),
            TextFormField(
              controller: _nomProprioController,
              decoration: InputDecoration(labelText: 'Nom Propriétaire'),
            ),
            TextFormField(
              controller: _telephoneProprioController,
              decoration: InputDecoration(labelText: 'Téléphone Propriétaire'),
            ),
            TextFormField(
              controller: _lieuLongController,
              decoration:
                  InputDecoration(labelText: 'Lieu de perte (longitude)'),
            ),
            TextFormField(
              controller: _lieuLatController,
              decoration:
                  InputDecoration(labelText: 'Lieu de perte (latitude)'),
            ),
            TextFormField(
              controller: _numChassisController,
              decoration: InputDecoration(labelText: 'Numéro de Chassis'),
            ),
            TextFormField(
              controller: _numPlaqueController,
              decoration: InputDecoration(labelText: 'Numéro de Plaque'),
            ),
            TextFormField(
              controller: _marqueController,
              decoration: InputDecoration(labelText: 'Marque du véhicule'),
            ),
            TextFormField(
              controller: _modeleController,
              decoration: InputDecoration(labelText: 'Modèle du véhicule'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateDeclaration();
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
