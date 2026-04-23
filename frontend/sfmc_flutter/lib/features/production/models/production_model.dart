class ProductionOrder {
  final int? id;
  final int productId;
  final String? productName;
  final double quantityTarget;
  final double quantityProduced;
  final String statut;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final int? machineId;
  final String? machineName;
  final String? notes;

  ProductionOrder({
    this.id,
    required this.productId,
    this.productName,
    required this.quantityTarget,
    this.quantityProduced = 0,
    this.statut = 'planned',
    this.dateDebut,
    this.dateFin,
    this.machineId,
    this.machineName,
    this.notes,
  });

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    return ProductionOrder(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantityTarget: json['quantity_target'].toDouble(),
      quantityProduced: json['quantity_produced'].toDouble(),
      statut: json['statut'],
      dateDebut: json['date_debut'] != null
          ? DateTime.parse(json['date_debut'])
          : null,
      dateFin: json['date_fin'] != null
          ? DateTime.parse(json['date_fin'])
          : null,
      machineId: json['machine_id'],
      machineName: json['machine_nom'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity_target': quantityTarget,
      'date_debut': dateDebut?.toIso8601String(),
      'machine_id': machineId,
      'notes': notes,
    };
  }
}

class Machine {
  final int id;
  final String nom;
  final String statut;
  final double capaciteJour;

  Machine({
    required this.id,
    required this.nom,
    required this.statut,
    required this.capaciteJour,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      nom: json['nom'],
      statut: json['statut'],
      capaciteJour: json['capacite_jour'].toDouble(),
    );
  }
}
