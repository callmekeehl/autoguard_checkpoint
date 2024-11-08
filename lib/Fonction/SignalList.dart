import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoguard_flutter/Constant.dart';
import '../Constant.dart';

class SignalList extends StatefulWidget {
  @override
  _SignalListState createState() => _SignalListState();
}

class _SignalListState extends State<SignalList> {
  List<dynamic> declarations = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDeclarations();
  }

  Future<void> _fetchDeclarations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? token = prefs.getString('authToken');

    if (userId == null || token == null) {
      setState(() {
        errorMessage = 'Erreur : Utilisateur non identifié.';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$url/api/declarations/utilisateur/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          declarations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur : Impossible de récupérer les déclarations.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de chargement des déclarations : $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste des Déclarations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade400,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
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
                        '${declaration['marque']} ${declaration['modele']}',
                      ),
                      subtitle: Text(
                          'Déclaré le: ${declaration['dateHeure']}\nPropriétaire: ${declaration['prenomProprio']} ${declaration['nomProprio']}'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        // Ajoutez une action pour afficher les détails de la déclaration
                      },
                    );
                  },
                ),
    );
  }
}
