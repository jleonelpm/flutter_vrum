import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String type; // 'new_question' | 'new_answer'
  final String vehicleId;
  final String? questionId;
  final String? message;
  final String? fromUserId;
  final DateTime createdAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.vehicleId,
    this.questionId,
    this.message,
    this.fromUserId,
    required this.createdAt,
    required this.read,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'] as Timestamp?;
    return AppNotification(
      id: id,
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      vehicleId: map['vehicleId'] as String? ?? '',
      questionId: map['questionId'] as String?,
      message: map['message'] as String?,
      fromUserId: map['fromUserId'] as String?,
      createdAt: ts != null ? ts.toDate() : DateTime.now(),
      read: map['read'] as bool? ?? false,
    );
  }
}
