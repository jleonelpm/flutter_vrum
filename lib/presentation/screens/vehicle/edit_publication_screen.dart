import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/vehicle_service.dart';
import '../../../data/services/storage_service.dart';

class EditPublicationScreen extends StatefulWidget {
  final String vehicleId;
  const EditPublicationScreen({super.key, required this.vehicleId});

  @override
  State<EditPublicationScreen> createState() => _EditPublicationScreenState();
}

class _EditPublicationScreenState extends State<EditPublicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController(text: '🚗');
  final _priceCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();
  final _service = VehicleService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();
  bool _loading = true;
  bool _saving = false;
  List<String> _existingImages = [];
  List<String> _newImagePaths = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _emojiCtrl.dispose();
    _priceCtrl.dispose();
    _lugarCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicle = await _service.getVehicleById(widget.vehicleId);
    if (vehicle != null) {
      _nameCtrl.text = vehicle.name;
      _descriptionCtrl.text = vehicle.description;
      _emojiCtrl.text = vehicle.emoji;
      _priceCtrl.text = vehicle.price.toString();
      _lugarCtrl.text = vehicle.lugar;
      _existingImages = List.from(vehicle.images);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickNewImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFiles.isEmpty) return;

      setState(() {
        _newImagePaths.addAll(pickedFiles.map((f) => f.path));
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pickedFiles.length} imagen(es) añadidas')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imágenes: $e')),
      );
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImagePaths.removeAt(index);
    });
  }

  void _removeExistingImage(String imageUrl) {
    setState(() {
      _existingImages.remove(imageUrl);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para editar')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      List<String> allImages = List.from(_existingImages);

      // Subir nuevas imágenes si las hay
      if (_newImagePaths.isNotEmpty) {
        final newUrls = await _storageService.uploadMultipleImages(
          _newImagePaths,
          widget.vehicleId,
        );
        allImages.addAll(newUrls);
      }

      // Eliminar imágenes que fueron removidas (opcional, depende de política de borrado)
      // Por ahora solo guardamos las que queremos mantener

      await _service.updateVehicle(widget.vehicleId, {
        'name': _nameCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'emoji': _emojiCtrl.text.trim().isNotEmpty
            ? _emojiCtrl.text.trim()
            : '🚗',
        'price': int.parse(_priceCtrl.text.trim()),
        'lugar': _lugarCtrl.text.trim(),
        'images': allImages,
      });
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Publicación actualizada')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Publicación'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Precio (USD)',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Ingresa un precio';
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa el lugar'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    // Sección de imágenes
                    _buildImagesSection(),
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
                      child: Text(
                        _saving ? 'Guardando...' : 'Actualizar Publicación',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imágenes',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Imágenes existentes
        if (_existingImages.isNotEmpty) ...[
          const Text(
            'Imágenes actuales:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final imageUrl = _existingImages[index];
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
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stackTrace) =>
                              const Center(child: Icon(Icons.image)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(imageUrl),
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
          const SizedBox(height: 12),
        ],
        // Botón para añadir nuevas imágenes
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickNewImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Añadir más imágenes'),
        ),
        // Nuevas imágenes seleccionadas
        if (_newImagePaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${_newImagePaths.length} imagen(es) nueva(s)',
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _newImagePaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_newImagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(index),
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
