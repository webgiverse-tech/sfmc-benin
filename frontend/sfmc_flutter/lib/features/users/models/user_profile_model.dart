class UserProfile {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String role;
  final String? adresse;
  final bool actif;
  final DateTime? createdAt;

  UserProfile({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.role,
    this.adresse,
    this.actif = true,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      role: json['role'],
      adresse: json['adresse'],
      actif: json['actif'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'adresse': adresse,
      'actif': actif,
    };
  }
}
