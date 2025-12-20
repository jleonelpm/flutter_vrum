import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getVehiclesStream() {
    return _firestore
        .collection('vehicles')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<VehicleModel?> getVehicleById(String vehicleId) async {
    try {
      final doc = await _firestore.collection('vehicles').doc(vehicleId).get();
      if (!doc.exists) return null;
      return VehicleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createVehicle(VehicleModel vehicle) async {
    try {
      await _firestore.collection('vehicles').add(vehicle.toMap());
    } catch (e) {
      rethrow;
    }
  }
}
