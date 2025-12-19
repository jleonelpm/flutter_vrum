import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'initial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.deepPurple,
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
                    const Text(
                      'Esta es la pantalla principal de la aplicacion.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
          ),
          // Título de publicaciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              'Publicaciones de Vehículos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Lista desplazable de vehículos
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                  return const Center(
                    child: Text('No hay vehículos disponibles'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final ts = data['createdAt'];
                    String published = '';
                    if (ts is Timestamp) {
                      final dt = ts.toDate();
                      published =
                          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                              .toString();
                    }
                    return _buildVehicleCard(
                      title: (data['name'] ?? '') as String,
                      description: (data['description'] ?? '') as String,
                      price: 'USD ${(data['price'] ?? 0).toString()}',
                      icon: (data['emoji'] ?? '🚗') as String,
                      publishedAt: published,
                      ownerName: (data['ownerName'] ?? 'Anónimo') as String,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showLogoutDialog(context);
        },
        backgroundColor: Colors.deepPurple,
        label: const Text('Cerrar Sesion'),
        icon: const Icon(Icons.logout),
      ),
    );
  }

  Widget _buildVehicleCard({
    required String title,
    required String description,
    required String price,
    required String icon,
    required String publishedAt,
    required String ownerName,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Imagen ilustrativa (icono)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(width: 12),
            // Información del vehículo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Por: $ownerName',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    publishedAt.isNotEmpty
                        ? 'Publicado: $publishedAt'
                        : 'Publicado: —',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesion'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                // Go back to initial screen after sign-out
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InitialScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Cerrar Sesion'),
            ),
          ],
        );
      },
    );
  }
}
