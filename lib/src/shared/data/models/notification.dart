import 'package:pocketbase/pocketbase.dart';

/// Model class for notifications
class NotificationModel {
  final String id;
  final String user;
  final String title;
  final String body;
  final String type;
  final bool read;
  final String redirectUrl;
  final DateTime created;
  final DateTime updated;

  /// Constructor for NotificationModel
  const NotificationModel({
    required this.id,
    required this.user,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.redirectUrl,
    required this.created,
    required this.updated,
  });

  /// Factory constructor to create a NotificationModel from a RecordModel
  factory NotificationModel.fromRecord(RecordModel record) {
    return NotificationModel(
      id: record.id,
      user: record.data['user'],
      title: record.data['title'],
      body: record.data['body'],
      type: record.data['type'],
      read: record.data['read'] ?? false,
      redirectUrl: record.data['redirect_url'] ?? '',
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
    );
  }

  /// Create a copy of this NotificationModel with the given fields replaced with the new values
  NotificationModel copyWith({
    String? id,
    String? user,
    String? title,
    String? body,
    String? type,
    bool? read,
    String? redirectUrl,
    DateTime? created,
    DateTime? updated,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      user: user ?? this.user,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      read: read ?? this.read,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
