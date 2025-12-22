import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../providers/search_provider.dart';
import '../../../data/services/search_service.dart';
import '../auth/initial_screen.dart';
import '../vehicle/vehicle_detail_screen.dart';
import '../vehicle/create_publication_screen.dart';
import '../vehicle/my_publications_screen.dart';
import '../../widgets/vehicle_card.dart';
import '../search/search_filter_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _vehicleStream() {
    return FirebaseFirestore.instance
        .collection('vehicles')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> _currentUserName() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) return 'Invitado';
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return email;
    final data = snap.docs.first.data();
    final name = data['fullName'];
    return (name is String && name.isNotEmpty) ? name : email;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const InitialScreen()),
                (_) => false,
              );
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchMode = ref.watch(searchModeProvider);
    final isSearchActive =
        ref.watch(basicSearchQueryProvider).isNotEmpty ||
        (searchMode == SearchMode.advanced &&
            (ref.watch(advancedSearchQueryProvider).isNotEmpty ||
                ref.watch(advancedSearchMinPriceProvider) != null ||
                ref.watch(advancedSearchMaxPriceProvider) != null ||
                ref.watch(advancedSearchLugarProvider).isNotEmpty));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de usuario
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<String>(
              future: _currentUserName(),
              builder: (context, snapshot) {
                final name = snapshot.data ?? 'Usuario';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario: $name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
          // Barra de búsqueda básica
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar vehículos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(basicSearchQueryProvider.notifier).state = value;
                      ref.read(basicSearchPageProvider.notifier).state = 0;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de filtros avanzados
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtros avanzados',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => SearchFilterModal(
                        onApply: () {
                          ref.read(searchModeProvider.notifier).state =
                              SearchMode.advanced;
                          ref.read(advancedSearchPageProvider.notifier).state =
                              0;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Título / Estado de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isSearchActive ? 'Resultados' : 'Vehículos',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyPublicationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.folder_shared,
                    color: Colors.deepPurple,
                  ),
                  label: const Text('Mis publicaciones'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Lista de resultados o vehículos
          Expanded(
            child: isSearchActive
                ? _buildSearchResults()
                : _buildVehiclesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePublicationScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer(
      builder: (context, ref, _) {
        final resultsAsync = ref.watch(activeSearchResultsProvider);
        final totalAsync = ref.watch(activeSearchTotalProvider);
        final currentPage = ref.watch(searchModeProvider) == SearchMode.basic
            ? ref.watch(basicSearchPageProvider)
            : ref.watch(advancedSearchPageProvider);

        return resultsAsync.when(
          data: (results) {
            return totalAsync.when(
              data: (total) {
                if (results.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron resultados'),
                  );
                }

                final totalPages = (total / SearchService.pageSize).ceil();
                final pageSize = SearchService.pageSize;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final vehicle = results[index];
                          final imageUrl = vehicle.images.isNotEmpty
                              ? vehicle.images.first
                              : null;

                          return VehicleCard(
                            vehicleId: vehicle.id,
                            title: vehicle.name,
                            description: vehicle.description,
                            price: 'USD ${vehicle.price}',
                            icon: vehicle.emoji,
                            publishedAt: vehicle.createdAt?.toString() ?? '',
                            ownerName: vehicle.ownerName,
                            imageUrl: imageUrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VehicleDetailScreen(
                                    vehicleId: vehicle.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Controles de paginación
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: currentPage > 0
                                  ? () {
                                      if (ref.watch(searchModeProvider) ==
                                          SearchMode.basic) {
                                        ref
                                                .read(
                                                  basicSearchPageProvider
                                                      .notifier,
                                                )
                                                .state =
                                            currentPage - 1;
                                      } else {
                                        ref
                                                .read(
                                                  advancedSearchPageProvider
                                                      .notifier,
                                                )
                                                .state =
                                            currentPage - 1;
                                      }
                                    }
                                  : null,
                            ),
                            Text(
                              'Página ${currentPage + 1} de $totalPages',
                              style: const TextStyle(fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: currentPage < totalPages - 1
                                  ? () {
                                      if (ref.watch(searchModeProvider) ==
                                          SearchMode.basic) {
                                        ref
                                                .read(
                                                  basicSearchPageProvider
                                                      .notifier,
                                                )
                                                .state =
                                            currentPage + 1;
                                      } else {
                                        ref
                                                .read(
                                                  advancedSearchPageProvider
                                                      .notifier,
                                                )
                                                .state =
                                            currentPage + 1;
                                      }
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        );
      },
    );
  }

  Widget _buildVehiclesList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _vehicleStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No hay vehículos disponibles'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final vehicleId = docs[index].id;
            final ts = data['createdAt'];
            final images = List<String>.from(data['images'] ?? []);
            String published = '';
            if (ts is Timestamp) {
              final dt = ts.toDate();
              published =
                  '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                      .toString();
            }
            return VehicleCard(
              vehicleId: vehicleId,
              title: (data['name'] ?? '') as String,
              description: (data['description'] ?? '') as String,
              price: 'USD ${(data['price'] ?? 0).toString()}',
              icon: (data['emoji'] ?? '🚗') as String,
              publishedAt: published,
              ownerName: (data['ownerName'] ?? 'Anónimo') as String,
              imageUrl: images.isNotEmpty ? images.first : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleDetailScreen(vehicleId: vehicleId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
