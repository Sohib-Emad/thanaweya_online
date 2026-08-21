/// Represents an in-app or push notification.
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String category;
  final String? link;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    this.body = '',
    this.category = 'system',
    this.link,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Extract link from top-level or data payload
    String? link = json['link']?.toString() ?? json['url']?.toString();
    if (link == null && json['data'] is Map) {
      final d = json['data'] as Map;
      link = d['link']?.toString() ?? d['url']?.toString();
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? 'system',
      link: link,
      isRead: json['is_read'] == true || json['isRead'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'category': category,
      if (link != null) 'link': link,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? category,
    String? link,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      link: link ?? this.link,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
