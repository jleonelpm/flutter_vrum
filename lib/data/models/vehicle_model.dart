import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String ownerEmail;
  final String ownerName;
  final String name;
  final String description;
  final String emoji;
  final int price;
  final String lugar;
  final DateTime? createdAt;

  VehicleModel({
    required this.id,
    required this.ownerEmail,
    required this.ownerName,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    required this.lugar,
    this.createdAt,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> map, String docId) {
    return VehicleModel(
      id: docId,
      ownerEmail: map['ownerEmail'] ?? '',
      ownerName: map['ownerName'] ?? 'Anónimo',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '🚗',
      price: map['price'] ?? 0,
      lugar: map['lugar'] ?? 'No especificado',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
      'name': name,
      'description': description,
      'emoji': emoji,
      'price': price,
      'lugar': lugar,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
