import 'package:autoguard_flutter/Constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListPolice extends StatefulWidget {
  @override
  _ListPoliceState createState() => _ListPoliceState();
}

class _ListPoliceState extends State<ListPolice> {
  List polices = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPolices();
  }

  Future<void> fetchPolices() async {
    final response = await http.get(
      Uri.parse('$url/api/polices'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        setState(() {
          polices = json.decode(response.body);
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
            'Erreur de chargement des polices: ${response.reasonPhrase}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Polices'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: polices.length,
                  itemBuilder: (context, index) {
                    final police = polices[index];
                    return ListTile(
                      title: Text('${police['prenom']} ${police['nom']}'),
                      subtitle: Text(police['email']),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPolice(police: police),
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

class EditPolice extends StatefulWidget {
  final Map police;

  EditPolice({required this.police});

  @override
  _EditPoliceState createState() => _EditPoliceState();
}

class _EditPoliceState extends State<EditPolice> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _adresseController;
  late TextEditingController _telephoneController;
  late TextEditingController _nomDepartementController;
  late TextEditingController _adresseDepartementController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.police['nom']);
    _prenomController = TextEditingController(text: widget.police['prenom']);
    _emailController = TextEditingController(text: widget.police['email']);
    _adresseController = TextEditingController(text: widget.police['adresse']);
    _telephoneController =
        TextEditingController(text: widget.police['telephone']);
    _nomDepartementController =
        TextEditingController(text: widget.police['nomDepartement']);
    _adresseDepartementController =
        TextEditingController(text: widget.police['adresseDepartement']);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _nomDepartementController.dispose();
    _adresseDepartementController.dispose();
    super.dispose();
  }

  Future<void> updatePolice() async {
    final response = await http.put(
      Uri.parse('$url/api/polices/${widget.police['policeId']}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'email': _emailController.text,
        'adresse': _adresseController.text,
        'telephone': _telephoneController.text,
        'nomDepartement': _nomDepartementController.text,
        'adresseDepartement': _adresseDepartementController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Informations de la police mises à jour'),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context,
          true); // Retourne à la liste des polices après la mise à jour
    } else {
      // Gérer les erreurs
      print('Updating police with ID: ${widget.police['policeId']}');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Erreur lors de la mise à jour de la police.'),
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
        title: Text('Modifier Police'),
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
              controller: _nomDepartementController,
              decoration: InputDecoration(labelText: 'Nom du Département'),
            ),
            TextFormField(
              controller: _adresseDepartementController,
              decoration: InputDecoration(labelText: 'Adresse du Département'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updatePolice();
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
