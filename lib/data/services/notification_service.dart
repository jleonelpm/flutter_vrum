import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  NotificationService({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('notifications');

  Stream<List<AppNotification>> notificationsForCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _col
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AppNotification.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<int> unreadCountForVehicle(String vehicleId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _col
        .where('userId', isEqualTo: user.uid)
        .where('vehicleId', isEqualTo: vehicleId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markReadForVehicle(String vehicleId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final snap = await _col
        .where('userId', isEqualTo: user.uid)
        .where('vehicleId', isEqualTo: vehicleId)
        .where('read', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }
}
