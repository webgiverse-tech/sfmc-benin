class Order {
  final int? id;
  final int clientId;
  final String statut;
  final DateTime dateCommande;
  final DateTime? dateLivraisonPrevue;
  final double total;
  final String? notes;
  final List<OrderItem> items;

  Order({
    this.id,
    required this.clientId,
    this.statut = 'pending',
    required this.dateCommande,
    this.dateLivraisonPrevue,
    this.total = 0,
    this.notes,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      clientId: json['client_id'],
      statut: json['statut'],
      dateCommande: DateTime.parse(json['date_commande']),
      dateLivraisonPrevue: json['date_livraison_prevue'] != null
          ? DateTime.parse(json['date_livraison_prevue'])
          : null,
      total: json['total'].toDouble(),
      notes: json['notes'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'date_livraison_prevue': dateLivraisonPrevue?.toIso8601String(),
      'notes': notes,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int? id;
  final int productId;
  final double quantity;
  final double prixUnitaire;

  OrderItem({
    this.id,
    required this.productId,
    required this.quantity,
    required this.prixUnitaire,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['product_id'],
      quantity: json['quantity'].toDouble(),
      prixUnitaire: json['prix_unitaire'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'prix_unitaire': prixUnitaire,
    };
  }
}
