class Utilisateur {
  final int utilisateurId;
  final String nom;
  final String prenom;
  final String email;
  final String adresse;
  final String telephone;
  final String type;

  Utilisateur({
    required this.utilisateurId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.adresse,
    required this.telephone,
    required this.type,
  });

  // Factory method pour créer une instance de Utilisateur à partir de JSON
  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      utilisateurId: json['utilisateurId'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      adresse: json['adresse'],
      telephone: json['telephone'],
      type: json['type'],
    );
  }

  // Méthode pour convertir une instance de Utilisateur en JSON
  Map<String, dynamic> toJson() {
    return {
      'utilisateurId': utilisateurId,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'adresse': adresse,
      'telephone': telephone,
      'type': type,
    };
  }
}
