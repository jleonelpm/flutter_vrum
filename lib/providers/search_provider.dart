import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/search_service.dart';
import '../../data/models/vehicle_model.dart';

final searchServiceProvider = Provider((ref) => SearchService());

// Estado para búsqueda básica
final basicSearchQueryProvider = StateProvider<String>((ref) => '');
final basicSearchPageProvider = StateProvider<int>((ref) => 0);

// Estado para búsqueda avanzada
final advancedSearchQueryProvider = StateProvider<String>((ref) => '');
final advancedSearchMinPriceProvider = StateProvider<int?>((ref) => null);
final advancedSearchMaxPriceProvider = StateProvider<int?>((ref) => null);
final advancedSearchLugarProvider = StateProvider<String>((ref) => '');
final advancedSearchPageProvider = StateProvider<int>((ref) => 0);

// State para modo de búsqueda
final searchModeProvider = StateProvider<SearchMode>((ref) => SearchMode.basic);

enum SearchMode { basic, advanced }

// Provider para resultados de búsqueda básica
final basicSearchResultsProvider = FutureProvider<List<VehicleModel>>((
  ref,
) async {
  final searchService = ref.watch(searchServiceProvider);
  final query = ref.watch(basicSearchQueryProvider);
  final page = ref.watch(basicSearchPageProvider);

  if (query.isEmpty) return [];
  return searchService.basicSearch(query, page: page);
});

// Provider para total de resultados búsqueda básica
final basicSearchTotalProvider = FutureProvider<int>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  final query = ref.watch(basicSearchQueryProvider);

  if (query.isEmpty) return 0;
  return searchService.getTotalResultsBasicSearch(query);
});

// Provider para resultados de búsqueda avanzada
final advancedSearchResultsProvider = FutureProvider<List<VehicleModel>>((
  ref,
) async {
  final searchService = ref.watch(searchServiceProvider);
  final query = ref.watch(advancedSearchQueryProvider);
  final minPrice = ref.watch(advancedSearchMinPriceProvider);
  final maxPrice = ref.watch(advancedSearchMaxPriceProvider);
  final lugar = ref.watch(advancedSearchLugarProvider);
  final page = ref.watch(advancedSearchPageProvider);

  // Si no hay ningún filtro, retornar vacío
  if (query.isEmpty && minPrice == null && maxPrice == null && lugar.isEmpty) {
    return [];
  }

  return searchService.advancedSearch(
    query: query,
    minPrice: minPrice,
    maxPrice: maxPrice,
    lugar: lugar,
    page: page,
  );
});

// Provider para total de resultados búsqueda avanzada
final advancedSearchTotalProvider = FutureProvider<int>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  final query = ref.watch(advancedSearchQueryProvider);
  final minPrice = ref.watch(advancedSearchMinPriceProvider);
  final maxPrice = ref.watch(advancedSearchMaxPriceProvider);
  final lugar = ref.watch(advancedSearchLugarProvider);

  if (query.isEmpty && minPrice == null && maxPrice == null && lugar.isEmpty) {
    return 0;
  }

  return searchService.getTotalResultsAdvancedSearch(
    query: query,
    minPrice: minPrice,
    maxPrice: maxPrice,
    lugar: lugar,
  );
});

// Provider para ubicaciones disponibles
final lugaresProvider = FutureProvider<List<String>>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.getUniqueLugares();
});

// Provider para obtener resultados activos (básica o avanzada)
final activeSearchResultsProvider = FutureProvider<List<VehicleModel>>((
  ref,
) async {
  final mode = ref.watch(searchModeProvider);
  if (mode == SearchMode.basic) {
    return ref.watch(basicSearchResultsProvider.future);
  } else {
    return ref.watch(advancedSearchResultsProvider.future);
  }
});

// Provider para obtener total activo
final activeSearchTotalProvider = FutureProvider<int>((ref) async {
  final mode = ref.watch(searchModeProvider);
  if (mode == SearchMode.basic) {
    return ref.watch(basicSearchTotalProvider.future);
  } else {
    return ref.watch(advancedSearchTotalProvider.future);
  }
});
