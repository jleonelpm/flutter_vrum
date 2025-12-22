import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/search_provider.dart';

class SearchFilterModal extends ConsumerStatefulWidget {
  final VoidCallback? onApply;

  const SearchFilterModal({super.key, this.onApply});

  @override
  ConsumerState<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends ConsumerState<SearchFilterModal> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _queryController;
  String? _selectedLugar;

  @override
  void initState() {
    super.initState();
    final minPrice = ref.read(advancedSearchMinPriceProvider);
    final maxPrice = ref.read(advancedSearchMaxPriceProvider);
    final query = ref.read(advancedSearchQueryProvider);
    final lugar = ref.read(advancedSearchLugarProvider);

    _minPriceController = TextEditingController(
      text: minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: maxPrice?.toString() ?? '',
    );
    _queryController = TextEditingController(text: query);
    _selectedLugar = lugar.isEmpty ? null : lugar;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lugaresAsync = ref.watch(lugaresProvider);

    return AlertDialog(
      title: const Text('Filtros avanzados'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de búsqueda por texto
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: 'Buscar por nombre o descripción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rango de precio - Stack vertical para mobile
              Column(
                children: [
                  TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio mínimo',
                      hintText: '0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio máximo',
                      hintText: '999999',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selector de lugar
              lugaresAsync.when(
                data: (lugares) {
                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedLugar,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todos los lugares'),
                      ),
                      ...lugares.map(
                        (lugar) =>
                            DropdownMenuItem(value: lugar, child: Text(lugar)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLugar = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Ubicación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset filters
            ref.read(advancedSearchQueryProvider.notifier).state = '';
            ref.read(advancedSearchMinPriceProvider.notifier).state = null;
            ref.read(advancedSearchMaxPriceProvider.notifier).state = null;
            ref.read(advancedSearchLugarProvider.notifier).state = '';
            _minPriceController.clear();
            _maxPriceController.clear();
            _queryController.clear();
            setState(() {
              _selectedLugar = null;
            });
          },
          child: const Text('Limpiar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          onPressed: () {
            // Validar y aplicar filtros
            try {
              final minPrice = _minPriceController.text.isEmpty
                  ? null
                  : int.parse(_minPriceController.text);
              final maxPrice = _maxPriceController.text.isEmpty
                  ? null
                  : int.parse(_maxPriceController.text);

              // Validar que maxPrice > minPrice si ambos están definidos
              if (minPrice != null && maxPrice != null && maxPrice < minPrice) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El precio máximo debe ser mayor al mínimo'),
                  ),
                );
                return;
              }

              // Actualizar providers
              ref.read(advancedSearchQueryProvider.notifier).state =
                  _queryController.text;
              ref.read(advancedSearchMinPriceProvider.notifier).state =
                  minPrice;
              ref.read(advancedSearchMaxPriceProvider.notifier).state =
                  maxPrice;
              ref.read(advancedSearchLugarProvider.notifier).state =
                  _selectedLugar ?? '';

              // Llamar callback y cerrar
              widget.onApply?.call();
              if (mounted) {
                Navigator.pop(context);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor ingresa valores válidos'),
                ),
              );
            }
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
