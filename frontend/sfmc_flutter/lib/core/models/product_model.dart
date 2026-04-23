class Product {
  final int id;
  final String nom;
  final String? description;
  final String categorie;
  final String unite;
  final double prixUnitaire;
  final String? imageUrl;
  final bool actif;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.nom,
    this.description,
    required this.categorie,
    required this.unite,
    required this.prixUnitaire,
    this.imageUrl,
    required this.actif,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      categorie: json['categorie'],
      unite: json['unite'],
      prixUnitaire: json['prix_unitaire'],
      imageUrl: json['image_url'],
      actif: json['actif'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
