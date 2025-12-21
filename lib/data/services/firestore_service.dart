import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snap = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return UserModel.fromMap(snap.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.email).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }
}
