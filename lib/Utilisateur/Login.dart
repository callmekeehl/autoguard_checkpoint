import 'dart:convert';
import 'package:autoguard_flutter/Type.dart';
import 'package:autoguard_flutter/Utilisateur/Home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant.dart';
import 'package:autoguard_flutter/Admin/HomeAdmin.dart';
import 'package:autoguard_flutter/Police/HomePolice.dart';
import 'package:autoguard_flutter/Garage/HomeGarage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Fonction pour gérer la connexion
  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });
    final String email = emailController.text;
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Veuillez remplir tous les champs.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    // URL du backend Flask
    const String _baseUrl = '$url/api/login';

    try {
      // Envoi de la requête HTTP POST pour l'authentification
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'motDePasse': password}),
      );

      if (response.statusCode == 200) {
        // Connexion réussie, stocker le token ou les informations de l'utilisateur
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Vérifiez si le token est présent et non null
        final token = responseData['token'];
        if (token == null) {
          _showErrorDialog("Token absent dans la réponse.");
          setState(() {
            isLoading = false;
          });
          return;
        }

        print(response.body); // Afficher la réponse brute de l'API
        print(responseData); // Afficher le mappage JSON décode
        print(token); // Afficher le token

        // Extraire les informations de l'utilisateur
        final user = responseData['user'];

        print(user); // Affiche les informations de l'utilisateur

        // Vérifier si l'objet 'user' est présent dans la réponse
        if (user == null) {
          _showErrorDialog(
              "Informations utilisateur absentes dans la réponse.");
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Enregistrer le token localement pour l'utiliser dans l'application
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('authToken', token);
        prefs.setInt('userId', user['utilisateurId'] ?? 'Non disponible');
        prefs.setString('userNom', user['nom'] ?? 'Non disponible');
        prefs.setString('userPrenom', user['prenom'] ?? 'Non disponible');
        prefs.setString('userEmail', user['email'] ?? 'Non disponible');
        prefs.setString('userAdresse', user['adresse'] ?? 'Non disponible');
        prefs.setString('userTelephone', user['telephone'] ?? 'Non disponible');

        // Stocker utilisateurId
        final utilisateurId = user['utilisateurId'];
        if (utilisateurId != null) {
          prefs.setInt('utilisateurId', utilisateurId);
        }

        if (user['type'] == 'police') {
          await prefs.setInt('policeId', user['policeId']);
          await prefs.setString('nomDepartement', user['nomDepartement']);
          await prefs.setString(
              'adresseDepartement', user['adresseDepartement']);
        }

        if (user['type'] == 'garage') {
          await prefs.setInt('garageId', user['garageId']);
          await prefs.setString('nomGarage', user['nomGarage']);
          await prefs.setString('adresseGarage', user['adresseGarage']);
        }

        // Ajout des champs pour le département et le garage
        prefs.setString(
            'nomDepartement', user['nomDepartement'] ?? 'Non disponible');
        prefs.setString('adresseDepartement',
            user['adresseDepartement'] ?? 'Non disponible');

        prefs.setString('nomGarage', user['nomGarage'] ?? 'Non disponible');
        prefs.setString(
            'adresseGarage', user['adresseGarage'] ?? 'Non disponible');

        // Afficher un message de succès (en bas de l'écran)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Connexion Réussie!'),
          backgroundColor: Colors.green,
        ));

        setState(() {
          isLoading = false;
        });

        // Naviguer vers l'écran principal
        // Vérifier le type de l'utilisateur et rediriger en conséquence
        switch (user['type']) {
          case 'admin':
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeAdmin()));
            break;
          case 'police':
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomePolice()));
            break;
          case 'garage':
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeGarage()));
            break;
          default:
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => Home()));
        }
      } else {
        // Afficher une erreur si la connexion a échoué
        _showErrorDialog(
            "Erreur de connexion. Veuillez vérifier vos informations.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Gérer toute autre exception possible
      _showErrorDialog("Une erreur est survenue: ${e.toString()}");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fonction pour afficher une boîte de dialogue d'erreur
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

  // Widgets pour les champs de texte
  Widget _buildEmail() {
    return TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Entrez votre Email";
          }
          return null;
        },
        controller: emailController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE7EDEB),
          hintText: "Entrer votre Email",
          prefixIcon: Icon(
            Icons.mail,
            color: Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ));
  }

  Widget _buildPassword() {
    return Container(
      child: TextFormField(
        obscureText: true, // Masquer le mot de passe
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Entrez votre Mot de passe";
          }
          return null;
        },
        controller: passwordController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE7EDEB),
          hintText: "Entrer votre mot de passe",
          prefixIcon: Icon(
            Icons.lock_rounded,
            color: Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

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
                      Text(
                        "Connexion",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "Connectez-vous pour continuer",
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
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEmail(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildPassword(),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Mot de passe oublié ?",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.blue[800],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600),
                            onPressed: isLoading ? null : _login,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18.0),
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(
                                      "Connexion",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80.0,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => Type()));
                          },
                          child: Text(
                            "Pas de compte ? Créer un",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.blue.shade800),
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
