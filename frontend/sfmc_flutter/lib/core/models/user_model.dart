class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String? telephone;
  final String? adresse;
  final String? avatarUrl;
  final bool actif;
  final DateTime createdAt;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.telephone,
    this.adresse,
    this.avatarUrl,
    required this.actif,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      avatarUrl: json['avatar_url'],
      actif: json['actif'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get fullName => '$prenom $nom';
}
