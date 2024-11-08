import 'dart:convert';
import 'package:autoguard_flutter/Garage/HomeGarage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoguard_flutter/Constant.dart';
import 'package:autoguard_flutter/Utilisateur/Login.dart';

class GarageSign extends StatefulWidget {
  const GarageSign({Key? key}) : super(key: key);

  @override
  State<GarageSign> createState() => _GarageSignState();
}

class _GarageSignState extends State<GarageSign> {
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final nomGarageController = TextEditingController();
  final adresseGarageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // URL de l'API pour l'inscription du garage
    const String _registerUrl = '$url/api/garages';

    try {
      final response = await http.post(
        Uri.parse(_registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nameController.text,
          'prenom': surnameController.text,
          'email': emailController.text,
          'adresse': addressController.text,
          'telephone': phoneController.text,
          'motDePasse': passwordController.text,
          'nomGarage': nomGarageController.text,
          'adresseGarage': adresseGarageController.text
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Récupérer le jeton JWT
        String? token = responseData['access_token'];
        int? userId;

        if (responseData['user_id'] != null) {
          // Convertir l'ID utilisateur en entier s'il est renvoyé en tant que chaîne de caractères
          userId = int.tryParse(responseData['user_id'].toString());
        }

        if (userId == null) {
          _showErrorDialog('ID utilisateur non trouvé ou incorrect.');
          setState(() {
            isLoading = false;
          });
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString('authToken', token);
        }

        await prefs.setInt('userId', userId);
        await prefs.setString('userNom', nameController.text);
        await prefs.setString('userPrenom', surnameController.text);
        await prefs.setString('userEmail', emailController.text);
        await prefs.setString('userAdresse', addressController.text);
        await prefs.setString('userTelephone', phoneController.text);
        await prefs.setString('nomGarage', nomGarageController.text);
        await prefs.setString('adresseGarage', adresseGarageController.text);

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Compte créé avec succès, mais le jeton est absent'),
            backgroundColor: Colors.orange,
          ));
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Compte de garage créé avec succès!'),
          backgroundColor: Colors.green,
        ));
        setState(() {
          isLoading = false;
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeGarage()));
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _showErrorDialog(
            responseData['message'] ?? 'Erreur lors de la création du compte.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showErrorDialog('Une erreur est survenue: ${e.toString()}');
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

  Widget _buildName() {
    return Container(
        child: TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Entrez votre Nom";
        }
        return null;
      },
      controller: nameController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFE7EDEB),
        hintText: "Entrer votre nom",
        prefixIcon: Icon(
          Icons.person,
          color: Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ));
  }

  Widget _buildSurname() {
    return Container(
        child: TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Entrez votre prénom";
        }
        return null;
      },
      controller: surnameController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFE7EDEB),
        hintText: "Entrer votre prénom",
        prefixIcon: Icon(
          Icons.person_outline,
          color: Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ));
  }

  Widget _buildEmail() {
    return Container(
      child: TextFormField(
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
          hintText: "Entrer votre email",
          prefixIcon: Icon(
            Icons.email_outlined,
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

  Widget _buildAddress() {
    return Container(
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Entrez votre adresse";
          }
          return null;
        },
        controller: addressController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE7EDEB),
          hintText: "Entrer votre adresse",
          prefixIcon: Icon(
            Icons.home_outlined,
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

  Widget _buildPhone() {
    return Container(
      child: TextFormField(
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Entrez votre numéro de téléphone";
          }
          return null;
        },
        controller: phoneController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE7EDEB),
          hintText: "Entrer votre numéro de téléphone",
          prefixIcon: Icon(
            Icons.phone,
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

  Widget _buildPassword() {
    return Container(
      child: TextFormField(
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Entrez votre mot de passe";
          }
          if (value.length < 6) {
            return "Le mot de passe doit contenir au moins 6 caractères";
          }
          return null;
        },
        controller: passwordController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE7EDEB),
          hintText: "Entrer votre mot de passe",
          prefixIcon: Icon(
            Icons.lock_outline,
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

  Widget _buildConfirmPassword() {
    return Container(
      child: TextFormField(
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Confirmez votre mot de passe";
          }
          if (value != passwordController.text) {
            return "Les mots de passe ne correspondent pas";
          }
          return null;
        },
        controller: confirmPasswordController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE7EDEB),
          hintText: "Confirmer votre mot de passe",
          prefixIcon: Icon(
            Icons.lock,
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

  Widget _buildGarageName() {
    return Container(
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Entrez le nom du garage";
          }
          return null;
        },
        controller: nomGarageController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE7EDEB),
          hintText: "Entrer le nom du garage",
          prefixIcon: Icon(
            Icons.business_center,
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

  Widget _buildGarageAddress() {
    return Container(
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Entrez l'adresse du garage";
          }
          return null;
        },
        controller: adresseGarageController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFE7EDEB),
          hintText: "Entrer l'adresse du garage",
          prefixIcon: Icon(
            Icons.location_city,
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
                        "Création de compte",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "Créer un compte pour continuer",
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildName(),
                            SizedBox(
                              height: 20.0,
                            ),
                            _buildSurname(),
                            SizedBox(
                              height: 20.0,
                            ),
                            _buildEmail(),
                            SizedBox(
                              height: 20.0,
                            ),
                            _buildAddress(),
                            SizedBox(
                              height: 20.0,
                            ),
                            _buildPhone(),
                            SizedBox(
                              height: 20.0,
                            ),
                            _buildPassword(),
                            SizedBox(
                              height: 20.0,
                            ),
                            _buildConfirmPassword(),
                            SizedBox(
                              height: 20.0,
                            ),
                            _buildGarageName(),
                            SizedBox(
                              height: 20.0,
                            ),
                            _buildGarageAddress(),
                            SizedBox(
                              height: 10.0,
                            ),
                            SizedBox(
                              height: 50.0,
                            ),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600),
                                onPressed: isLoading ? null : _register,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18.0),
                                  child: isLoading
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : Text(
                                          "Créer",
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
                                    MaterialPageRoute(builder: (_) => Login()));
                              },
                              child: Text(
                                "Déjà un compte ? Connectez-vous",
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
