// lib/services/calculator_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cctv_calculator/models/camera_group.dart'; // Importamos tu modelo

class CalculatorService {
  late Map<String, dynamic> _bitrateData;
  bool isInitialized = false; // Para saber si ya cargamos los datos

  List<String> codecOptions = [];
  List<String> resolutionOptions = [];
  List<String> fpsOptions = [];

  // 1. Cargar la "DB" de JSON en memoria
  Future<void> loadBitrateData() async {
    final String response = await rootBundle.loadString('assets/data/bitrates.json');
    _bitrateData = await json.decode(response);

    // --- AÑADE ESTA LÓGICA NUEVA ---
    // ¡Aquí generamos las opciones para la UI!
    codecOptions = _bitrateData.keys.toList(); // ["H.265", "H.264"]

    // Usamos Sets para evitar duplicados
    final Set<String> resolutions = {};
    final Set<String> fps = {};

    // Bucle 1: Reemplaza _bitrateData.forEach
    for (var resMap in _bitrateData.values) {
      // Bucle 2: Reemplaza resMap.forEach
      for (var fpsMap in (resMap as Map<String, dynamic>).values) {
        // Bucle 3: Reemplaza fpsMap.keys.forEach
        for (var f in (fpsMap as Map<String, dynamic>).keys) {
          fps.add(f);
        }
      }
      // Agregamos las resoluciones aquí
      resolutions.addAll((resMap).keys);
    }

    // Convertimos los Sets a Listas
    resolutionOptions = resolutions.toList();
    fpsOptions = fps.toList();
    // ---------------------------------

    isInitialized = true;
  }

  // 2. Función para obtener el Bitrate
  int? getBitrate({
    required String codec,
    required String resolution,
    required String fps,
  }) {
    if (!isInitialized) {
      debugPrint("Error: El servicio no está inicializado. Llama a loadBitrateData()");
      return null;
    }
    try {
      // Navega el JSON: data["H.265"]["5MP"]["15"]
      return _bitrateData[codec][resolution][fps];
    } catch (e) {
      // Si la combinación no existe, devuelve 0
      debugPrint("Combinación no encontrada: $codec, $resolution, $fps");
      return null;
    }
  }

  // 3. La fórmula "mágica"
  double _calculateGbPerDay(int bitrateKbps) {
    if (bitrateKbps == 0) return 0;
    // (Kbps * 0.0108) = GB/Día
    return (bitrateKbps * 0.0108);
  }

  // 4. La función principal que usará la UI
  Map<String, double> calculateStorage({
    required List<CameraGroup> cameraGroups,
    required double diskSizeTB,
    required double activityFactorPercent,
  }) {
    double totalGbPerDay = 0;

    for (var group in cameraGroups) {
      final int? bitrate = getBitrate(
        codec: group.codec,
        resolution: group.resolution,
        fps: group.fps,
      );
      // ¡Solo sumamos si el bitrate es válido!
      if (bitrate != null) { 
        totalGbPerDay += _calculateGbPerDay(bitrate) * group.quantity;
      }
    }

    double diskSizeGB = diskSizeTB * 1000;
    
    // Evitar división por cero
    if (totalGbPerDay == 0 || activityFactorPercent == 0) {
      return {'totalGbPerDay': 0, 'worstCaseDays': 0, 'averageCaseDays': 0};
    }

    double worstCaseDays = diskSizeGB / totalGbPerDay;
    double averageCaseDays = worstCaseDays / (activityFactorPercent / 100);

    return {
      'totalGbPerDay': totalGbPerDay,
      'worstCaseDays': worstCaseDays,
      'averageCaseDays': averageCaseDays,
    };
  }
}