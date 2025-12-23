import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/vehicle_service.dart';
import '../../widgets/vehicle_card.dart';
import 'edit_publication_screen.dart';
import '../../screens/qa/qa_screen.dart';
import '../../../providers/notification_provider.dart';

class MyPublicationsScreen extends ConsumerWidget {
  const MyPublicationsScreen({super.key});

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text(
          '¿Seguro que deseas eliminarla? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = FirebaseAuth.instance.currentUser?.email;
    final vehicleService = VehicleService();

    if (email == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Publicaciones')),
        body: const Center(
          child: Text('Inicia sesión para ver tus publicaciones'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Publicaciones'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: vehicleService.getMyVehiclesStream(email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No tienes publicaciones aún'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final vehicleId = docs[index].id;
              final images = List<String>.from(data['images'] ?? []);
              final isSold = data['isSold'] ?? false;
              final unreadAsync = ref.watch(
                unreadCountForVehicleProvider(vehicleId),
              );

              return Dismissible(
                key: ValueKey(vehicleId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) async {
                  try {
                    await vehicleService.deleteVehicle(vehicleId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Publicación eliminada')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al eliminar: $e')),
                      );
                    }
                  }
                },
                child: Stack(
                  children: [
                    Opacity(
                      opacity: isSold ? 0.6 : 1.0,
                      child: VehicleCard(
                        vehicleId: vehicleId,
                        title: (data['name'] ?? '') as String,
                        description: (data['description'] ?? '') as String,
                        price: 'USD ${(data['price'] ?? 0).toString()}',
                        icon: (data['emoji'] ?? '🚗') as String,
                        publishedAt: _formatTimestamp(data['createdAt']),
                        ownerName: (data['ownerName'] ?? 'Anónimo') as String,
                        imageUrl: images.isNotEmpty ? images.first : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditPublicationScreen(vehicleId: vehicleId),
                            ),
                          );
                        },
                      ),
                    ),
                    if (isSold)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'VENDIDO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Preguntas button with unread badge
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.help_outline,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Preguntas y respuestas',
                                onPressed: () async {
                                  // Mark notifications read on open
                                  await ref
                                      .read(notificationServiceProvider)
                                      .markReadForVehicle(vehicleId);
                                  if (context.mounted) {
                                    final currentUid =
                                        FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid ??
                                        '';
                                    final ownerId =
                                        (data['ownerId'] ?? '') as String;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => QAScreen(
                                          vehicleId: vehicleId,
                                          sellerUserId: ownerId.isNotEmpty
                                              ? ownerId
                                              : currentUid,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              unreadAsync.when(
                                data: (count) => count > 0
                                    ? Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                loading: () => const SizedBox.shrink(),
                                error: (e, st) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              isSold ? Icons.restart_alt : Icons.check_circle,
                              color: isSold ? Colors.orange : Colors.green,
                            ),
                            tooltip: isSold
                                ? 'Marcar como disponible'
                                : 'Marcar como vendido',
                            onPressed: () async {
                              try {
                                await vehicleService.toggleSoldStatus(
                                  vehicleId,
                                  !isSold,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSold
                                            ? 'Vehículo marcado como disponible'
                                            : 'Vehículo marcado como vendido',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
