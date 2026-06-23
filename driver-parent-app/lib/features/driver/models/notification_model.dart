class NotificationModel {
  final int notificationId;
  final String title;
  final String message;
  final String type;
  final String category;
  final String status;
  final int? sentAt;
  final int? readAt;

  const NotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.status,
    required this.sentAt,
    required this.readAt,
  });

  bool get isUnread => status.toUpperCase() == 'SENT';

  NotificationModel copyWith({
    int? notificationId,
    String? title,
    String? message,
    String? type,
    String? category,
    String? status,
    int? sentAt,
    int? readAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
    );
  }

  factory NotificationModel.fromApiResponse(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: _toInt(json['notificationId'] ?? json['id']),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? json['body'] ?? '').toString(),
      type: (json['type'] ?? json['notificationType'] ?? 'INFO').toString(),
      category: (json['category'] ?? 'GENERAL').toString(),
      status: _parseStatus(json),
      sentAt: _toNullableInt(
        json['sentAt'] ?? json['createdAt'] ?? json['timestamp'],
      ),
      readAt: _toNullableInt(json['readAt'] ?? json['updatedAt']),
    );
  }

  static String _parseStatus(Map<String, dynamic> json) {
    if (json['status'] != null) return json['status'].toString();
    if (json['read'] == true) return 'READ';
    if (json['isRead'] == true) return 'READ';
    return 'SENT';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}