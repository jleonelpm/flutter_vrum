import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/vehicle_service.dart';
import '../../widgets/vehicle_card.dart';
import 'edit_publication_screen.dart';

class MyPublicationsScreen extends StatelessWidget {
  MyPublicationsScreen({super.key});

  final _service = VehicleService();

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
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
        stream: _service.getMyVehiclesStream(email),
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final vehicleId = docs[index].id;
              final ts = data['createdAt'];
              String published = '';
              if (ts is Timestamp) {
                final dt = ts.toDate();
                published =
                    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }
              return VehicleCard(
                vehicleId: vehicleId,
                title: (data['name'] ?? '') as String,
                description: (data['description'] ?? '') as String,
                price: 'USD ${(data['price'] ?? 0).toString()}',
                icon: (data['emoji'] ?? '🚗') as String,
                publishedAt: published,
                ownerName: (data['ownerName'] ?? 'Anónimo') as String,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditPublicationScreen(vehicleId: vehicleId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
