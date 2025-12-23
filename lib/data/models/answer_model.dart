import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerModel {
  final String id;
  final String questionId;
  final String vehicleId;
  final String responderUserId;
  final String text;
  final DateTime createdAt;

  const AnswerModel({
    required this.id,
    required this.questionId,
    required this.vehicleId,
    required this.responderUserId,
    required this.text,
    required this.createdAt,
  });

  AnswerModel copyWith({
    String? id,
    String? questionId,
    String? vehicleId,
    String? responderUserId,
    String? text,
    DateTime? createdAt,
  }) {
    return AnswerModel(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      vehicleId: vehicleId ?? this.vehicleId,
      responderUserId: responderUserId ?? this.responderUserId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AnswerModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'] as Timestamp?;
    return AnswerModel(
      id: id,
      questionId: map['questionId'] as String,
      vehicleId: map['vehicleId'] as String,
      responderUserId: map['responderUserId'] as String,
      text: map['text'] as String,
      createdAt: ts != null ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'vehicleId': vehicleId,
      'responderUserId': responderUserId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
