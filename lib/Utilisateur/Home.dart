import 'package:autoguard_flutter/AccountInfo.dart';
import 'package:autoguard_flutter/Admin/ListNotification.dart';
import 'package:autoguard_flutter/Fonction/DemandeRdv.dart';
import 'package:autoguard_flutter/Fonction/Signal.dart';
import 'package:autoguard_flutter/Fonction/VehiculeRetrouve.dart';
import 'package:autoguard_flutter/Fonction/Verification.dart';
import 'package:autoguard_flutter/Utilisateur/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Fonction/Calendar.dart';
import '../Fonction/SignalList.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Login()));
    } else {}
  }

  void _navigateToSignalement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Signal()),
    );
  }

  void _navigateToRdv() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DemandeRdv()),
    );
  }

  void _navigateToNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListNotification()),
    );
  }

  void _navigateToVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Verification()),
    );
  }

  void _navigateToSignalList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignalList()),
    );
  }

  void _navigateToCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );
  }

  void _navigateToVehiculeRetrouve() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VehiculeRetrouve()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                height: 130,
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
                              fontFamily: 'bungee',
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
                              size: 40,
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
                          height: 5,
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToSignalement(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "./assets/images/theft.png",
                                        height: 80,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Faire un \nsignalement",
                                            style: TextStyle(
                                                fontFamily: 'bungee',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Vous pouvez déclarer ici \nun véhicule volé ou perdu",
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
                                      Image.asset(
                                        "./assets/images/rdv.png",
                                        height: 80,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Rendez-vous",
                                            style: TextStyle(
                                                fontFamily: 'bungee',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Vous pouvez prendre ici \nun rendez-vous avec les \nautorités",
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
                              onTap: () => _navigateToVehiculeRetrouve(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "./assets/images/loupe.png",
                                        height: 60,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Déclarer un \nvéhicule retrouvé",
                                            style: TextStyle(
                                                fontFamily: 'bungee',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            "Vous pouvez déclarer ici un \nengin retrouvé",
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
                                      Image.asset(
                                        "./assets/images/notification.png",
                                        height: 80,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Notifications",
                                            style: TextStyle(
                                                fontFamily: 'bungee',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Vous pouvez voir ici \nvos notifications",
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
                              onTap: () => _navigateToVerification(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "./assets/images/check.png",
                                        height: 80,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Vérification",
                                            style: TextStyle(
                                                fontFamily: 'bungee',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Vous pouvez faire ici \nles vérifications si des \nvéhicules ont été déclarés \nou non",
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
                              onTap: () => _navigateToSignalList(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "./assets/images/list.png",
                                        height: 80,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Liste des \ndéclaration",
                                            style: TextStyle(
                                                fontFamily: 'bungee',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Vous pouvez voir ici \nla liste des véhicules \nque vous avez déclarés",
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
                              onTap: () => _navigateToCalendar(),
                              child: Card(
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                color: Colors.blue.shade200,
                                elevation: 14,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "./assets/images/calendar.png",
                                        height: 80,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Calendrier",
                                            style: TextStyle(
                                                fontFamily: 'bungee',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            "Vous pouvez voir ici \nla liste de vos rendez-vous",
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
