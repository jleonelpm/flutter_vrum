import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/services/vehicle_service.dart';

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
  bool _loading = true;
  bool _saving = false;

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
    }
    if (mounted) setState(() => _loading = false);
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
      await _service.updateVehicle(widget.vehicleId, {
        'name': _nameCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'emoji': _emojiCtrl.text.trim().isNotEmpty
            ? _emojiCtrl.text.trim()
            : '🚗',
        'price': int.parse(_priceCtrl.text.trim()),
        'lugar': _lugarCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
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
}
