import 'package:autoguard_flutter/AccountInfo.dart';
import 'package:autoguard_flutter/Admin/ListDeclaration.dart';
import 'package:autoguard_flutter/Admin/ListGarage.dart';
import 'package:autoguard_flutter/Admin/ListNotification.dart';
import 'package:autoguard_flutter/Admin/ListPolice.dart';
import 'package:autoguard_flutter/Admin/ListRdv.dart';
import 'package:autoguard_flutter/Admin/ListUtilisateur.dart';
import 'package:autoguard_flutter/Utilisateur/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAdmin extends StatefulWidget {
  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      // Si aucun jeton n'est trouvé, redirigez vers la page de connexion
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Login()));
    } else {}
  }

  void _navigateToUtilisateur() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListUtilisateur()),
    );
  }

  void _navigateToDeclaration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListDeclaration()),
    );
  }

  void _navigateToRdv() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListRdv()),
    );
  }

  void _navigateToNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListNotification()),
    );
  }

  void _navigateToGarage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListGarage()),
    );
  }

  void _navigateToPolice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListPolice()),
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
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Tête de page (AppBar)
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 36.0, horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Autoguard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AccountInfo()),
                              );
                            },
                            icon: Icon(
                              Icons.account_circle_outlined,
                              color: Colors.white,
                              size: 36,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Contenu de la page ici
                        Text("Bienvenue",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToUtilisateur(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person,
                                          size: 80, color: Colors.black54),
                                      SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Utilisateur",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Gérez les utilisateurs \nde l'application",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            GestureDetector(
                              onTap: () => _navigateToDeclaration(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Icon(Icons.report,
                                          size: 80, color: Colors.black54),
                                      SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Déclaration",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Listes des véhicules \nvolés ou perdus",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            GestureDetector(
                              onTap: () => _navigateToRdv(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month,
                                          size: 80, color: Colors.black54),
                                      SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Rendez-vous",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Listes des rendez-vous \navec les autorités",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            GestureDetector(
                              onTap: () => _navigateToNotification(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Icon(Icons.notification_important,
                                          size: 80, color: Colors.black54),
                                      SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Notifications",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Gérez toutes les notifications",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            GestureDetector(
                              onTap: () => _navigateToGarage(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Icon(Icons.garage_rounded,
                                          size: 80, color: Colors.black54),
                                      SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Garage",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Gérez les garages",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            GestureDetector(
                              onTap: () => _navigateToPolice(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Icon(Icons.local_police,
                                          size: 80, color: Colors.black54),
                                      SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Police",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Gérez les comptes police",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
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
