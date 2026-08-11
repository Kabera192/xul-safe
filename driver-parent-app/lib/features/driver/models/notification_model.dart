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

  /// Human-friendly send time, e.g. "5m ago", "Yesterday, 3:45 PM",
  /// or "Jan 5, 3:45 PM" for anything older.
  String get formattedSentAt {
    final ts = sentAt;
    if (ts == null) return '';

    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && dt.day == now.day) return '${diff.inHours}h ago';

    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour12:$minute $period';

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;
    if (isYesterday) return 'Yesterday, $timeStr';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr = dt.year == now.year
        ? '${months[dt.month - 1]} ${dt.day}'
        : '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    return '$dateStr, $timeStr';
  }

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