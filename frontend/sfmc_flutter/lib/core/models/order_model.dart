class Order {
  final int id;
  final int clientId;
  final String statut;
  final DateTime dateCommande;
  final String? dateLivraisonPrevue;
  final double total;
  final String? notes;
  List<OrderItem> items;

  Order({
    required this.id,
    required this.clientId,
    required this.statut,
    required this.dateCommande,
    this.dateLivraisonPrevue,
    required this.total,
    this.notes,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      clientId: json['client_id'],
      statut: json['statut'],
      dateCommande: DateTime.parse(json['date_commande']),
      dateLivraisonPrevue: json['date_livraison_prevue'],
      total: json['total'],
      notes: json['notes'],
      items:
          (json['items'] as List?)
              ?.map((i) => OrderItem.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final double quantity;
  final double prixUnitaire;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.prixUnitaire,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      prixUnitaire: json['prix_unitaire'],
    );
  }
}
