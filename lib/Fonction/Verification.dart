import 'dart:convert';
import 'package:autoguard_flutter/Constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final plaqueController = TextEditingController();
  final chassisController = TextEditingController();
  bool isLoading = false;

  Future<void> _verifyDetails() async {
    setState(() {
      isLoading = true;
    });

    final plaque = plaqueController.text;
    final chassis = chassisController.text;

    final String apiUrl = '$url/api/verifier_declaration';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numPlaque': plaque,
          'numChassis': chassis,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['found']) {
          _showDialog('Les informations ont été trouvées dans la déclaration.');
        } else {
          _showDialog('Aucune déclaration trouvée pour ces informations.');
        }
      } else {
        _showDialog('Erreur lors de la vérification. Veuillez réessayer.');
      }
    } catch (e) {
      _showDialog('Une erreur est survenue: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Résultat de la vérification'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Vérification',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: plaqueController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFE7EDEB),
                  hintText: 'Numéro de Plaque',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: chassisController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFE7EDEB),
                  hintText: 'Numéro de chassis',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: isLoading ? null : _verifyDetails,
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        'Vérifier',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
