import 'package:flutter/material.dart';

class ListRdv extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Rendez-vous'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: ListView.builder(
        itemCount: 10, // Remplacez par le nombre réel de rendez-vous
        itemBuilder: (context, index) {
          return ListTile(
            title:
                Text('Rendez-vous $index'), // Remplacez par les données réelles
            subtitle: Text(
                'Détails du rendez-vous $index'), // Remplacez par les données réelles
          );
        },
      ),
    );
  }
}
