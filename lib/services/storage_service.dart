// lib/services/storage_service.dart

import 'dart:convert'; // Para codificar y decodificar JSON
import 'package:cctv_calculator/models/camera_group.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definimos un nombre para nuestro archivo de guardado
const String _projectDataKey = 'projectData';

class StorageService {

  // --- FUNCIÓN DE GUARDADO ---
  Future<void> saveProject({
    required List<CameraGroup> cameraGroups,
    required double diskSizeTB,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Convertimos nuestra lista de objetos CameraGroup
    //    en una lista de Mapas (List<Map<String, dynamic>>)
    final List<Map<String, dynamic>> cameraListJson =
        cameraGroups.map((group) => group.toJson()).toList();

    // 2. Creamos un "contenedor" JSON para guardar todo
    final Map<String, dynamic> projectData = {
      'diskSizeTB': diskSizeTB,
      'cameraGroups': cameraListJson,
      // (En el futuro, podríamos guardar el 'activityFactor' global aquí si volviéramos)
    };

    // 3. Convertimos ese contenedor en un solo string de texto
    final String jsonString = json.encode(projectData);

    // 4. Guardamos ese string en la memoria del teléfono
    await prefs.setString(_projectDataKey, jsonString);
  }

  // --- FUNCIÓN DE CARGADO ---
  // Esta función devuelve un "Mapa" con los datos, o null si no hay nada guardado.
  Future<Map<String, dynamic>?> loadProject() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Leemos el string de texto de la memoria
    final String? jsonString = prefs.getString(_projectDataKey);

    // Si no hay nada guardado, devolvemos null
    if (jsonString == null) {
      return null;
    }

    // 2. Convertimos el string de vuelta a un Mapa
    final Map<String, dynamic> projectData = json.decode(jsonString);

    // 3. Leemos los datos del Mapa
    final double diskSizeTB = projectData['diskSizeTB'] ?? 1.0;
    
    // Leemos la lista de cámaras (que es una List<dynamic> en este punto)
    final List<dynamic> cameraListJson = projectData['cameraGroups'] ?? [];

    // 4. Convertimos la lista de mapas de vuelta a una lista de objetos CameraGroup
    final List<CameraGroup> cameraGroups = cameraListJson
        .map((jsonGroup) => CameraGroup.fromJson(jsonGroup))
        .toList();

    // 5. Devolvemos los datos listos para que la UI los use
    return {
      'diskSizeTB': diskSizeTB,
      'cameraGroups': cameraGroups,
    };
  }
}