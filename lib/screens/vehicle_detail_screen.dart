import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleDetailScreen extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Vehículo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('vehicles')
            .doc(vehicleId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Vehículo no encontrado'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? '';
          final description = data['description'] ?? '';
          final emoji = data['emoji'] ?? '🚗';
          final price = data['price'] ?? 0;
          final ownerName = data['ownerName'] ?? 'Anónimo';
          final ownerEmail = data['ownerEmail'] ?? '';
          final lugar = data['lugar'] ?? 'No especificado';
          final createdAt = data['createdAt'];

          String publishedDate = '';
          if (createdAt is Timestamp) {
            final dt = createdAt.toDate();
            publishedDate =
                '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero section con emoji
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.deepPurple.shade400,
                        Colors.deepPurple.shade700,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 120)),
                  ),
                ),

                // Contenido
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del vehículo
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Precio
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.attach_money,
                              color: Colors.green,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'USD ${price.toString()}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ubicación
                      _buildInfoSection(
                        icon: Icons.location_on,
                        iconColor: Colors.red,
                        title: 'Ubicación',
                        content: lugar,
                      ),
                      const SizedBox(height: 20),

                      // Descripción
                      _buildInfoSection(
                        icon: Icons.description,
                        iconColor: Colors.blue,
                        title: 'Descripción',
                        content: description,
                      ),
                      const SizedBox(height: 20),

                      // Información del propietario
                      _buildInfoSection(
                        icon: Icons.person,
                        iconColor: Colors.deepPurple,
                        title: 'Publicado por',
                        content: ownerName,
                        subtitle: ownerEmail,
                      ),
                      const SizedBox(height: 20),

                      // Fecha de publicación
                      if (publishedDate.isNotEmpty)
                        _buildInfoSection(
                          icon: Icons.calendar_today,
                          iconColor: Colors.orange,
                          title: 'Fecha de publicación',
                          content: publishedDate,
                        ),
                      const SizedBox(height: 32),

                      // Botón de contacto
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar contacto
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Contactar a $ownerName (Próximamente)',
                                ),
                                backgroundColor: Colors.deepPurple,
                              ),
                            );
                          },
                          icon: const Icon(Icons.message),
                          label: const Text(
                            'Contactar al vendedor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
