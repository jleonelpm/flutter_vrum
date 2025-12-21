import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/vehicle_service.dart';
import '../../widgets/vehicle_card.dart';
import 'edit_publication_screen.dart';

class MyPublicationsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              );
            },
          );
        },
      ),
    );
  }
}
