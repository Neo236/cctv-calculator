// lib/widgets/camera_group_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cctv_calculator/models/camera_group.dart';

// --- CAMBIO 1: Convertido a StatefulWidget ---
class CameraGroupCard extends StatefulWidget {
  const CameraGroupCard({
    super.key,
    required this.cameraGroup,
    required this.onUpdate,
    required this.onDelete,
    required this.codecOptions,
    required this.resolutionOptions,
    required this.fpsOptions,
    required this.isCombinationValid,
    this.bitrate,
    required this.gbPerDay,
  });

  final CameraGroup cameraGroup;
  final Function(CameraGroup newGroup) onUpdate;
  final VoidCallback onDelete;
  final List<String> codecOptions;
  final List<String> resolutionOptions;
  final List<String> fpsOptions;
  final bool isCombinationValid;
  final int? bitrate;
  final double gbPerDay;

  @override
  State<CameraGroupCard> createState() => _CameraGroupCardState();
}

class _CameraGroupCardState extends State<CameraGroupCard> {
  // --- CAMBIO 2: Controladores movidos al Estado ---
  late final TextEditingController _quantityController;
  late final TextEditingController _activityFactorController;

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los valores del modelo
    _quantityController = TextEditingController(
      text: widget.cameraGroup.quantity.toString(),
    );
    _activityFactorController = TextEditingController(
      text: widget.cameraGroup.activityFactor.toString(),
    );
  }

  @override
  void dispose() {
    // Limpia los controladores
    _quantityController.dispose();
    _activityFactorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // --- FILA 1: CANTIDAD, ACTIVIDAD Y BORRAR ---
            Row(
              children: [
                // Campo de Cantidad
                SizedBox(
                  width: 80, // Un poco más pequeño
                  child: TextField(
                    controller: _quantityController, // Usa el controlador de estado
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Cant.', // Etiqueta más corta
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final newQuantity = int.tryParse(value) ?? 1;
                      // Actualiza el objeto "padre"
                      widget.onUpdate(widget.cameraGroup..quantity = newQuantity);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // --- CAMBIO 3: AÑADIDO CAMPO DE ACTIVIDAD ---
                SizedBox(
                  width: 80, // Un poco más pequeño
                  child: TextField(
                    controller: _activityFactorController, // Usa el controlador de estado
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Activ. %', // Etiqueta más corta
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final newFactor = double.tryParse(value) ?? 40.0;
                      // Actualiza el objeto "padre"
                      widget.onUpdate(widget.cameraGroup..activityFactor = newFactor);
                    },
                  ),
                ),
                // ------------------------------------------

                const Spacer(), // Ocupa el espacio restante

                // Botón de Borrar
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- FILA 2: MENÚS DESPLEGABLES ---
            Row(
              children: [
                // Menú Codec
                Expanded(
                  child: _buildDropdown(
                    label: 'Codec',
                    value: widget.cameraGroup.codec,
                    options: widget.codecOptions,
                    onChanged: (newValue) {
                      widget.onUpdate(widget.cameraGroup..codec = newValue!);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Menú Resolución
                Expanded(
                  child: _buildDropdown(
                    label: 'Resolución',
                    value: widget.cameraGroup.resolution,
                    options: widget.resolutionOptions,
                    onChanged: (newValue) {
                      widget.onUpdate(widget.cameraGroup..resolution = newValue!);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Menú FPS
                Expanded(
                  child: _buildDropdown(
                    label: 'FPS',
                    value: widget.cameraGroup.fps,
                    options: widget.fpsOptions,
                    onChanged: (newValue) {
                      widget.onUpdate(widget.cameraGroup..fps = newValue!);
                    },
                  ),
                ),
              ],
            ),

            // --- RESULTADOS / ADVERTENCIA DE GRUPO ---
            const SizedBox(height: 12),
            if (widget.isCombinationValid) ...[
              // Si es válido, muestra los resultados del grupo
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(widget.bitrate! / 1024).toStringAsFixed(1)} Mbps',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const Text('  |  ', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${widget.gbPerDay.toStringAsFixed(1)} GB/Día',
                    style: TextStyle(
                        color: Colors.grey[400], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ] else ...[
              // Si es inválido, muestra la advertencia
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.yellow[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Combinación no válida.',
                      style: TextStyle(color: Colors.yellow[700]),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Helper para construir un DropdownButton de forma limpia
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    // ... (esta función no cambia en absoluto) ...
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: value,
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}