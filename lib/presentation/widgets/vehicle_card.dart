import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final String vehicleId;
  final String title;
  final String description;
  final String price;
  final String icon;
  final String publishedAt;
  final String ownerName;
  final VoidCallback onTap;
  final String? imageUrl; // Thumbnail de la primera imagen
  final bool isSold;

  const VehicleCard({
    super.key,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.publishedAt,
    required this.ownerName,
    required this.onTap,
    this.imageUrl,
    this.isSold = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Opacity(
            opacity: isSold ? 0.7 : 1.0,
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Imagen o icono
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: imageUrl != null
                            ? Border.all(color: Colors.deepPurple)
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stackTrace) => Center(
                                  child: Text(
                                    icon,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
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
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            publishedAt.isNotEmpty
                                ? 'Publicado: $publishedAt'
                                : 'Publicado: —',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
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
            ),
          ),
          if (isSold)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'VENDIDO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
