import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String vehicleId;
  final String buyerUserId;
  final String sellerUserId;
  final String text;
  final DateTime createdAt;
  final int answerCount;

  const QuestionModel({
    required this.id,
    required this.vehicleId,
    required this.buyerUserId,
    required this.sellerUserId,
    required this.text,
    required this.createdAt,
    this.answerCount = 0,
  });

  List<String> get participants => [buyerUserId, sellerUserId];

  QuestionModel copyWith({
    String? id,
    String? vehicleId,
    String? buyerUserId,
    String? sellerUserId,
    String? text,
    DateTime? createdAt,
    int? answerCount,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      buyerUserId: buyerUserId ?? this.buyerUserId,
      sellerUserId: sellerUserId ?? this.sellerUserId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      answerCount: answerCount ?? this.answerCount,
    );
  }

  factory QuestionModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'] as Timestamp?;
    return QuestionModel(
      id: id,
      vehicleId: map['vehicleId'] as String,
      buyerUserId: map['buyerUserId'] as String,
      sellerUserId: map['sellerUserId'] as String,
      text: map['text'] as String,
      createdAt: ts != null ? ts.toDate() : DateTime.now(),
      answerCount: (map['answerCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'buyerUserId': buyerUserId,
      'sellerUserId': sellerUserId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'answerCount': answerCount,
      'participants': participants,
    };
  }
}
