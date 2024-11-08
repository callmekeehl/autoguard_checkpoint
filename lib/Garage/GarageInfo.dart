import 'package:autoguard_flutter/Utilisateur/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GarageInfo extends StatefulWidget {
  @override
  _GarageInfoState createState() => _GarageInfoState();
}

class _GarageInfoState extends State<GarageInfo> {
  String? nom;
  String? prenom;
  String? email;
  String? adresse;
  String? telephone;
  String? nomGarage;
  String? adresseGarage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Effacer toutes les informations de l'utilisateur

    // Naviguer vers l'écran de connexion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nom = prefs.getString('userNom') ?? 'Non disponible';
      prenom = prefs.getString('userPrenom') ?? 'Non disponible';
      email = prefs.getString('userEmail') ?? 'Non disponible';
      adresse = prefs.getString('userAdresse') ?? 'Non disponible';
      telephone = prefs.getString('userTelephone') ?? 'Non disponible';
      nomGarage = prefs.getString('nomGarage') ?? 'Non disponible';
      adresseGarage = prefs.getString('adresseGarage') ?? 'Non disponible';
      print('Nom Garage: $nomGarage');
      print('Adresse Garage: $adresseGarage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(
        title: Text(
          'Informations du Compte',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Nom', nom),
            _buildInfoCard('Prenom', prenom),
            _buildInfoCard('Email', email),
            _buildInfoCard('Adresse', adresse),
            _buildInfoCard('Téléphone', telephone),
            _buildInfoCard('Nom Garage', nomGarage),
            _buildInfoCard('Adresse Garage', adresseGarage),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                ),
                child: Text(
                  'Déconnexion',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String? value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700]),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? 'Non disponible',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}