// lib/widgets/camera_group_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cctv_calculator/models/camera_group.dart';

class CameraGroupCard extends StatelessWidget {
  const CameraGroupCard({
    super.key,
    required this.cameraGroup,
    required this.onUpdate,
    required this.onDelete,
    required this.codecOptions,
    required this.resolutionOptions,
    required this.fpsOptions,
  });

  final CameraGroup cameraGroup;
  final Function(CameraGroup newGroup) onUpdate;
  final VoidCallback onDelete;
  final List<String> codecOptions;
  final List<String> resolutionOptions;
  final List<String> fpsOptions;

  @override
  Widget build(BuildContext context) {
    // Usamos un controlador temporal para el campo de cantidad
    final quantityController = TextEditingController(
      text: cameraGroup.quantity.toString(),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // --- FILA 1: CANTIDAD Y BORRAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Campo de Cantidad
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Actualiza el objeto "padre" cuando el valor cambia
                      final newQuantity = int.tryParse(value) ?? 1;
                      onUpdate(cameraGroup..quantity = newQuantity);
                    },
                  ),
                ),
                // Botón de Borrar
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: onDelete,
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
                    value: cameraGroup.codec,
                    options: codecOptions,
                    onChanged: (newValue) {
                      onUpdate(cameraGroup..codec = newValue!);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Menú Resolución
                Expanded(
                  child: _buildDropdown(
                    label: 'Resolución',
                    value: cameraGroup.resolution,
                    options: resolutionOptions,
                    onChanged: (newValue) {
                      onUpdate(cameraGroup..resolution = newValue!);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Menú FPS
                Expanded(
                  child: _buildDropdown(
                    label: 'FPS',
                    value: cameraGroup.fps,
                    options: fpsOptions,
                    onChanged: (newValue) {
                      onUpdate(cameraGroup..fps = newValue!);
                    },
                  ),
                ),
              ],
            ),
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
    return DropdownButtonFormField<String>(
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