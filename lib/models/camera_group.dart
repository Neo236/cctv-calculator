// lib/models/camera_group.dart

class CameraGroup {
  int quantity;
  String codec;
  String resolution;
  String fps;
  double activityFactor;

  CameraGroup({
    this.quantity = 1,
    this.codec = 'H.265',
    this.resolution = '1080p',
    this.fps = '15',
    this.activityFactor = 40.0,
  });

  // --- AÑADIDO: MÉTODO 1 (Convertir DE Clase A JSON) ---
  // Convierte nuestra instancia de CameraGroup en un Mapa
  // que json.encode() pueda entender.
  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'codec': codec,
      'resolution': resolution,
      'fps': fps,
      'activityFactor': activityFactor,
    };
  }

  // --- AÑADIDO: MÉTODO 2 (Convertir DE JSON A Clase) ---
  // Un "constructor de fábrica" que crea una instancia de CameraGroup
  // a partir de un Mapa (que viene de json.decode()).
  factory CameraGroup.fromJson(Map<String, dynamic> json) {
    return CameraGroup(
      quantity: json['quantity'] ?? 1,
      codec: json['codec'] ?? 'H.265',
      resolution: json['resolution'] ?? '1080p',
      fps: json['fps'] ?? '15',
      activityFactor: json['activityFactor'] ?? 40.0,
    );
  }
}