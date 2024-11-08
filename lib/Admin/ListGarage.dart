import 'package:autoguard_flutter/Constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListGarage extends StatefulWidget {
  @override
  _ListGarageState createState() => _ListGarageState();
}

class _ListGarageState extends State<ListGarage> {
  List garages = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchGarages();
  }

  Future<void> fetchGarages() async {
    final response = await http.get(
      Uri.parse('$url/api/garages'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        setState(() {
          garages = json.decode(response.body);
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
            'Erreur de chargement des garages: ${response.reasonPhrase}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Garages'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: garages.length,
                  itemBuilder: (context, index) {
                    final garage = garages[index];
                    return ListTile(
                      title: Text('${garage['nom']} ${garage['prenom']}'),
                      subtitle: Text(garage['email']),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditGarage(garage: garage),
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

class EditGarage extends StatefulWidget {
  final Map garage;

  EditGarage({required this.garage});

  @override
  _EditGarageState createState() => _EditGarageState();
}

class _EditGarageState extends State<EditGarage> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _adresseController;
  late TextEditingController _telephoneController;
  late TextEditingController _nomGarageController; // Nouveau champ
  late TextEditingController _adresseGarageController; // Nouveau champ

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.garage['nom']);
    _prenomController = TextEditingController(text: widget.garage['prenom']);
    _emailController = TextEditingController(text: widget.garage['email']);
    _adresseController = TextEditingController(text: widget.garage['adresse']);
    _telephoneController =
        TextEditingController(text: widget.garage['telephone']);
    _nomGarageController = TextEditingController(
        text: widget.garage['nomGarage']); // Initialisation
    _adresseGarageController = TextEditingController(
        text: widget.garage['adresseGarage']); // Initialisation
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _nomGarageController.dispose();
    _adresseGarageController.dispose();
    super.dispose();
  }

  Future<void> updateGarage() async {
    final response = await http.put(
      Uri.parse('$url/api/garages/${widget.garage['garageId']}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'email': _emailController.text,
        'adresse': _adresseController.text,
        'telephone': _telephoneController.text,
        'nomGarage': _nomGarageController.text, // Envoi du nouveau champ
        'adresseGarage':
            _adresseGarageController.text, // Envoi du nouveau champ
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Informations du garage mises à jour'),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context,
          true); // Retourne à la liste des garages après la mise à jour
    } else {
      // Gérer les erreurs
      print('Updating garage with ID: ${widget.garage['garageId']}');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Erreur lors de la mise à jour du garage.'),
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
        title: Text('Modifier Garage'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextFormField(
              controller: _prenomController,
              decoration: InputDecoration(labelText: 'Prénom'),
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
            TextFormField(
              controller: _nomGarageController,
              decoration: InputDecoration(labelText: 'Nom du Garage'),
            ),
            TextFormField(
              controller: _adresseGarageController,
              decoration: InputDecoration(labelText: 'Adresse du Garage'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateGarage();
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
