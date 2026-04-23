class AppNotification {
  final int id;
  final int userId;
  final String titre;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.titre,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      titre: json['titre'],
      message: json['message'],
      type: json['type'],
      read: json['read'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      userId: userId,
      titre: titre,
      message: message,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
