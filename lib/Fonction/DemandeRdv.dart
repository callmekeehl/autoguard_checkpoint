import 'package:autoguard_flutter/Constant.dart';
import 'package:autoguard_flutter/Utilisateur/Home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DemandeRdv extends StatefulWidget {
  @override
  _DemandeRdvState createState() => _DemandeRdvState();
}

class _DemandeRdvState extends State<DemandeRdv> {
  int? userId;
  String? nom;
  String? prenom;
  String? email;
  String? adresse;
  String? telephone;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController _motifController = TextEditingController();
  final dateHeureController = TextEditingController();
  DateTime? selectedDateTime;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateHeureController.text =
              '${selectedDateTime!.toLocal()}'.split(' ')[0] +
                  ' ${pickedTime.format(context)}';
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Erreur"),
        content: Text(message),
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
  }

  Widget _buildDateTimeField() {
    return GestureDetector(
      onTap: () async {
        await _selectDateTime(context);
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: dateHeureController,
          decoration: InputDecoration(
            labelText: 'Date et Heure',
            icon: Icon(Icons.calendar_today),
            filled: true,
            fillColor: Color(0xFFE7EDEB),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          validator: (value) {
            if (selectedDateTime == null) {
              return 'Veuillez sélectionner une date et une heure';
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      userId =
          prefs.getInt('userId'); // Assurez-vous que l'utilisateurId est stocké

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Vous devez être connecté pour soumettre une demande de rendez-vous.')),
        );
        return;
      }

      final motif = _motifController.text;
      final dateHeure = selectedDateTime?.toIso8601String();

      final motifData = {
        'utilisateurId': userId,
        'motifDescription': motif,
        'date': dateHeure,
      };

      try {
        final response = await http.post(
          Uri.parse('$url/api/motifs'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(motifData),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Demande de rendez-vous soumise avec succès.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => Home()));
        } else {
          _showErrorDialog(
              'Erreur lors de la soumission de la demande de rendez-vous.');
        }
      } catch (e) {
        _showErrorDialog("Une erreur est survenue: ${e.toString()}");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      nom = prefs.getString('userNom') ?? 'Non disponible';
      prenom = prefs.getString('userPrenom') ?? 'Non disponible';
      email = prefs.getString('userEmail') ?? 'Non disponible';
      adresse = prefs.getString('userAdresse') ?? 'Non disponible';
      telephone = prefs.getString('userTelephone') ?? 'Non disponible';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade800,
                Colors.blue.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 36.0, horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Demande de Rendez-vous",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 9.0),
                    Text(
                      "Remplissez le formulaire pour continuer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _motifController,
                          decoration: InputDecoration(
                            labelText: 'Motif',
                            icon: Icon(Icons.note),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un motif';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildDateTimeField(),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Text(
                                    "Soumettre",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                    ),
                                  ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
