class StockItem {
  final int id;
  final int productId;
  final String? productName;
  final int warehouseId;
  final String? warehouseName;
  final double quantity;
  final double seuilCritique;
  final DateTime updatedAt;

  StockItem({
    required this.id,
    required this.productId,
    this.productName,
    required this.warehouseId,
    this.warehouseName,
    required this.quantity,
    required this.seuilCritique,
    required this.updatedAt,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      warehouseId: json['warehouse_id'],
      warehouseName: json['warehouse_name'],
      quantity: json['quantity'].toDouble(),
      seuilCritique: json['seuil_critique'].toDouble(),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class StockMovement {
  final int? id;
  final int productId;
  final int warehouseId;
  final String type; // 'IN' ou 'OUT'
  final double quantity;
  final String? reason;
  final DateTime? date;
  final int? userId;

  StockMovement({
    this.id,
    required this.productId,
    required this.warehouseId,
    required this.type,
    required this.quantity,
    this.reason,
    this.date,
    this.userId,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      productId: json['product_id'],
      warehouseId: json['warehouse_id'],
      type: json['type'],
      quantity: json['quantity'].toDouble(),
      reason: json['reason'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'warehouse_id': warehouseId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'user_id': userId,
    };
  }
}
