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

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyVehiclesStream(
    String email,
  ) {
    return _firestore
        .collection('vehicles')
        .where('ownerEmail', isEqualTo: email)
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

  /// Crear vehículo y retornar la referencia del documento (para acceder al ID).
  Future<DocumentReference<Map<String, dynamic>>> createVehicleAndGetRef(
    VehicleModel vehicle,
  ) async {
    try {
      return await _firestore.collection('vehicles').add(vehicle.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateVehicle(
    String vehicleId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
