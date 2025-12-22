import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int pageSize = 10;

  /// Valida y sanitiza entrada de búsqueda
  String _sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]'), '');
  }

  /// Búsqueda básica: por nombre o descripción
  /// Retorna pagina de resultados
  Future<List<VehicleModel>> basicSearch(String query, {int page = 0}) async {
    try {
      final sanitized = _sanitizeInput(query);
      if (sanitized.isEmpty) return [];

      final searchLower = sanitized.toLowerCase();

      final snapshot = await _firestore
          .collection('vehicles')
          .orderBy('createdAt', descending: true)
          .get();

      final results = snapshot.docs
          .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
          .where((vehicle) {
            final nameLower = vehicle.name.toLowerCase();
            final descLower = vehicle.description.toLowerCase();
            return nameLower.contains(searchLower) ||
                descLower.contains(searchLower);
          })
          .toList();

      // Aplicar paginación
      final startIndex = page * pageSize;
      final endIndex = startIndex + pageSize;
      if (startIndex >= results.length) return [];
      return results.sublist(
        startIndex,
        endIndex > results.length ? results.length : endIndex,
      );
    } catch (e) {
      throw Exception('Error en búsqueda básica: $e');
    }
  }

  /// Búsqueda avanzada con filtros
  /// [query]: búsqueda por texto (opcional)
  /// [minPrice]: precio mínimo (opcional)
  /// [maxPrice]: precio máximo (opcional)
  /// [lugar]: ubicación (opcional, búsqueda parcial)
  Future<List<VehicleModel>> advancedSearch({
    String query = '',
    int? minPrice,
    int? maxPrice,
    String lugar = '',
    int page = 0,
  }) async {
    try {
      final sanitizedQuery = _sanitizeInput(query).toLowerCase();
      final sanitizedLugar = _sanitizeInput(lugar).toLowerCase();

      final snapshot = await _firestore
          .collection('vehicles')
          .orderBy('createdAt', descending: true)
          .get();

      final results = snapshot.docs
          .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
          .where((vehicle) {
            // Filtro por texto
            if (sanitizedQuery.isNotEmpty) {
              final nameLower = vehicle.name.toLowerCase();
              final descLower = vehicle.description.toLowerCase();
              if (!nameLower.contains(sanitizedQuery) &&
                  !descLower.contains(sanitizedQuery)) {
                return false;
              }
            }

            // Filtro por precio
            if (minPrice != null && vehicle.price < minPrice) return false;
            if (maxPrice != null && vehicle.price > maxPrice) return false;

            // Filtro por ubicación
            if (sanitizedLugar.isNotEmpty) {
              final lugarLower = vehicle.lugar.toLowerCase();
              if (!lugarLower.contains(sanitizedLugar)) return false;
            }

            return true;
          })
          .toList();

      // Aplicar paginación
      final startIndex = page * pageSize;
      final endIndex = startIndex + pageSize;
      if (startIndex >= results.length) return [];
      return results.sublist(
        startIndex,
        endIndex > results.length ? results.length : endIndex,
      );
    } catch (e) {
      throw Exception('Error en búsqueda avanzada: $e');
    }
  }

  /// Obtener total de resultados para paginación
  Future<int> getTotalResultsBasicSearch(String query) async {
    try {
      final sanitized = _sanitizeInput(query);
      if (sanitized.isEmpty) return 0;

      final searchLower = sanitized.toLowerCase();
      final snapshot = await _firestore.collection('vehicles').get();

      return snapshot.docs
          .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
          .where((vehicle) {
            final nameLower = vehicle.name.toLowerCase();
            final descLower = vehicle.description.toLowerCase();
            return nameLower.contains(searchLower) ||
                descLower.contains(searchLower);
          })
          .length;
    } catch (e) {
      throw Exception('Error contando resultados: $e');
    }
  }

  /// Obtener total de resultados para búsqueda avanzada
  Future<int> getTotalResultsAdvancedSearch({
    String query = '',
    int? minPrice,
    int? maxPrice,
    String lugar = '',
  }) async {
    try {
      final sanitizedQuery = _sanitizeInput(query).toLowerCase();
      final sanitizedLugar = _sanitizeInput(lugar).toLowerCase();

      final snapshot = await _firestore.collection('vehicles').get();

      return snapshot.docs
          .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
          .where((vehicle) {
            if (sanitizedQuery.isNotEmpty) {
              final nameLower = vehicle.name.toLowerCase();
              final descLower = vehicle.description.toLowerCase();
              if (!nameLower.contains(sanitizedQuery) &&
                  !descLower.contains(sanitizedQuery)) {
                return false;
              }
            }
            if (minPrice != null && vehicle.price < minPrice) return false;
            if (maxPrice != null && vehicle.price > maxPrice) return false;
            if (sanitizedLugar.isNotEmpty) {
              final lugarLower = vehicle.lugar.toLowerCase();
              if (!lugarLower.contains(sanitizedLugar)) return false;
            }
            return true;
          })
          .length;
    } catch (e) {
      throw Exception('Error contando resultados: $e');
    }
  }

  /// Obtener todas las ubicaciones únicas (para sugerencias)
  Future<List<String>> getUniqueLugares() async {
    try {
      final snapshot = await _firestore.collection('vehicles').get();
      final lugares = snapshot.docs
          .map((doc) => (doc.data()['lugar'] ?? '') as String)
          .where((lugar) => lugar.isNotEmpty)
          .toSet()
          .toList();
      lugares.sort();
      return lugares;
    } catch (e) {
      throw Exception('Error obteniendo ubicaciones: $e');
    }
  }
}
