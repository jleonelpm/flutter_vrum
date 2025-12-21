import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/services/vehicle_service.dart';
import '../../../data/services/storage_service.dart';

class CreatePublicationScreen extends StatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  State<CreatePublicationScreen> createState() =>
      _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends State<CreatePublicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController(text: '🚗');
  final _priceCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();
  bool _saving = false;
  final _service = VehicleService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();
  List<String> _selectedImagePaths = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _emojiCtrl.dispose();
    _priceCtrl.dispose();
    _lugarCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFiles.isEmpty) return;

      setState(() {
        _selectedImagePaths = pickedFiles.map((f) => f.path).toList();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedImagePaths.length} imágenes seleccionadas'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imágenes: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para publicar')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      // Crear documento de vehículo primero (para obtener ID)
      final vehicleDoc = await _service.createVehicleAndGetRef(
        VehicleModel(
          ownerEmail: user.email!,
          ownerName: user.displayName ?? user.email!,
          name: _nameCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          emoji: _emojiCtrl.text.isNotEmpty ? _emojiCtrl.text.trim() : '🚗',
          price: int.parse(_priceCtrl.text.trim()),
          lugar: _lugarCtrl.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      List<String> imageUrls = [];

      // Subir imágenes si las hay
      if (_selectedImagePaths.isNotEmpty) {
        imageUrls = await _storageService.uploadMultipleImages(
          _selectedImagePaths,
          vehicleDoc.id,
        );

        // Actualizar documento con URLs de imágenes
        await vehicleDoc.update({'images': imageUrls});
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación creada exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del vehículo',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa una descripción'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emojiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Emoji (opcional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio (USD)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa un precio';
                  final value = int.tryParse(v.trim());
                  if (value == null || value <= 0)
                    return 'Ingresa un número mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lugarCtrl,
                decoration: const InputDecoration(labelText: 'Lugar'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el lugar' : null,
              ),
              const SizedBox(height: 20),
              // Sección de imágenes
              _buildImageSection(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_saving ? 'Guardando...' : 'Crear Publicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imágenes (opcional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickImages,
          icon: const Icon(Icons.image),
          label: const Text('Seleccionar imágenes'),
        ),
        if (_selectedImagePaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${_selectedImagePaths.length} imagen(es) seleccionada(s)',
            style: const TextStyle(color: Colors.green, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImagePaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
