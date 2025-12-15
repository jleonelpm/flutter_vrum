import 'package:flutter/material.dart';
import 'initial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Datos estáticos de vehículos
  static final List<Map<String, String>> vehicles = [
    {
      'title': 'Toyota Corolla 2022',
      'description': 'Sedán compacto en excelentes condiciones',
      'price': '\$18,500',
      'icon': '🏎️',
    },
    {
      'title': 'Honda Civic 2020',
      'description': 'Sedán deportivo, poco kilometraje',
      'price': '\$16,800',
      'icon': '🚗',
    },
    {
      'title': 'Chevrolet Malibu 2021',
      'description': 'Sedán de lujo con características premium',
      'price': '\$19,200',
      'icon': '🚙',
    },
    {
      'title': 'Ford Fusion 2019',
      'description': 'Vehículo familiar confiable',
      'price': '\$14,500',
      'icon': '🏎️',
    },
    {
      'title': 'BMW Serie 3 2023',
      'description': 'Vehículo premium con tecnología avanzada',
      'price': '\$45,000',
      'icon': '🚗',
    },
    {
      'title': 'Mazda CX-5 2021',
      'description': 'SUV compacto versátil y eficiente',
      'price': '\$28,500',
      'icon': '🚙',
    },
  ];

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuario: Juan Perez',
                  style: TextStyle(
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                return _buildVehicleCard(
                  title: vehicles[index]['title']!,
                  description: vehicles[index]['description']!,
                  price: vehicles[index]['price']!,
                  icon: vehicles[index]['icon']!,
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
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
              onPressed: () {
                Navigator.pop(context);
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
