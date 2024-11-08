import 'dart:convert';
import 'dart:io';
import 'package:autoguard_flutter/Constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoguard_flutter/Constant.dart';

class VehiculeRetrouve extends StatefulWidget {
  @override
  _VehiculeRetrouveState createState() => _VehiculeRetrouveState();
}

class _VehiculeRetrouveState extends State<VehiculeRetrouve> {
  bool isLoading = false;
  final nomRetrouveurController = TextEditingController();
  final prenomRetrouveurController = TextEditingController();
  final numPlaqueController = TextEditingController();
  final lieuLongController = TextEditingController();
  final lieuLatController = TextEditingController();
  final marqueController = TextEditingController();
  final modeleController = TextEditingController();
  final dateHeureController = TextEditingController();

  LatLng _selectedPosition = LatLng(6.125552372407288, 1.2103758524443544);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateHeureController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final dateTime =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        dateHeureController.text += " " + picked.format(context);
      });
    }
  }

  bool _validateFields() {
    if (nomRetrouveurController.text.isEmpty ||
        prenomRetrouveurController.text.isEmpty ||
        numPlaqueController.text.isEmpty ||
        lieuLongController.text.isEmpty ||
        lieuLatController.text.isEmpty ||
        marqueController.text.isEmpty ||
        modeleController.text.isEmpty ||
        dateHeureController.text.isEmpty) {
      _showErrorDialog("Veuillez remplir tous les champs.");
      return false;
    }
    return true;
  }

  Future<void> _submitRetrouve() async {
    if (!_validateFields()) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
    final utilisateurId = prefs.getInt('userId');

    if (utilisateurId == null) {
      _showErrorDialog("Utilisateur non identifié. Veuillez vous reconnecter.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final retrouveData = {
      'utilisateurId': utilisateurId,
      'nomRetrouveur': nomRetrouveurController.text,
      'prenomRetrouveur': prenomRetrouveurController.text,
      'numPlaque': numPlaqueController.text,
      'lieuLong': lieuLongController.text,
      'lieuLat': lieuLatController.text,
      'marque': marqueController.text,
      'modele': modeleController.text,
      'dateHeure': dateHeureController.text,
    };

    const String _baseUrl = '$url/api/vehiculeRetrouve';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(retrouveData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Enregistrement du véhicule retrouvé réussi!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      } else {
        _showErrorDialog(
            "Erreur lors de l'envoi des données. Veuillez réessayer.");
      }
    } catch (e) {
      _showErrorDialog("Une erreur est survenue: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
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

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFE7EDEB),
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
      String hintText, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        await _selectDate(context);
        await _selectTime(context);
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFE7EDEB),
            hintText: hintText,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSelector() {
    return Container(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          center: _selectedPosition,
          zoom: 15,
          onTap: (tapPosition, LatLng latlng) {
            setState(() {
              _selectedPosition = latlng;
              lieuLatController.text = latlng.latitude.toString();
              lieuLongController.text = latlng.longitude.toString();
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPosition,
                builder: (ctx) => Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: media.width,
            maxHeight: media.height,
          ),
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
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 36.0, horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                        "Véhicule Retrouvé",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        "Enregistrez les détails du véhicule retrouvé",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
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
                    child: ListView(
                      children: [
                        _buildTextField(
                            "Nom du Retrouveur", nomRetrouveurController),
                        SizedBox(height: 20.0),
                        _buildTextField(
                            "Prénom du Retrouveur", prenomRetrouveurController),
                        SizedBox(height: 20.0),
                        _buildTextField("Numéro Plaque", numPlaqueController),
                        SizedBox(height: 20.0),
                        _buildMapSelector(),
                        SizedBox(height: 20.0),
                        _buildTextField("Marque", marqueController),
                        SizedBox(height: 20.0),
                        _buildTextField("Modèle", modeleController),
                        SizedBox(height: 20.0),
                        _buildDateTimeField(
                            "Date et Heure", dateHeureController),
                        SizedBox(height: 50.0),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                            ),
                            onPressed: isLoading ? null : _submitRetrouve,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18.0),
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(
                                      "Enregistrer",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
