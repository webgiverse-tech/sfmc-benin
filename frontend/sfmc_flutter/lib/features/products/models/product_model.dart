class Product {
  final int? id;
  final String nom;
  final String? description;
  final String categorie;
  final String unite;
  final double prixUnitaire;
  final String? imageUrl;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.nom,
    this.description,
    required this.categorie,
    required this.unite,
    required this.prixUnitaire,
    this.imageUrl,
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      categorie: json['categorie'],
      unite: json['unite'],
      prixUnitaire: json['prix_unitaire'].toDouble(),
      imageUrl: json['image_url'],
      actif: json['actif'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'description': description,
      'categorie': categorie,
      'unite': unite,
      'prix_unitaire': prixUnitaire,
      'image_url': imageUrl,
      'actif': actif ? 1 : 0,
    };
  }

  Product copyWith({
    int? id,
    String? nom,
    String? description,
    String? categorie,
    String? unite,
    double? prixUnitaire,
    String? imageUrl,
    bool? actif,
  }) {
    return Product(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      categorie: categorie ?? this.categorie,
      unite: unite ?? this.unite,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      imageUrl: imageUrl ?? this.imageUrl,
      actif: actif ?? this.actif,
    );
  }
}
