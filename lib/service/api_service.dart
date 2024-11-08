// lib/services/utilisateur_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:autoguard_flutter/models/Utilisateur.dart';
import 'package:autoguard_flutter/Constant.dart';

class UtilisateurService {
  final String _baseUrl = url; // Remplacez par l'URL de votre API Flask

  Future<List<Utilisateur>> fetchUtilisateurs() async {
    final response = await http.get(Uri.parse('$_baseUrl/utilisateurs'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Utilisateur.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load utilisateurs');
    }
  }

  Future<Utilisateur> fetchUtilisateur(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/utilisateurs/$id'));

    if (response.statusCode == 200) {
      return Utilisateur.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load utilisateur');
    }
  }

  Future<void> createUtilisateur(Utilisateur utilisateur) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/utilisateurs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(utilisateur.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create utilisateur');
    }
  }

  Future<void> updateUtilisateur(Utilisateur utilisateur) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/utilisateurs/${utilisateur.utilisateurId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(utilisateur.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update utilisateur');
    }
  }

  Future<void> deleteUtilisateur(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/utilisateurs/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete utilisateur');
    }
  }
}
