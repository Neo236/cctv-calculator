// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cctv_calculator/models/camera_group.dart';
import 'package:cctv_calculator/services/calculator_service.dart';
import 'package:cctv_calculator/services/storage_service.dart';
import 'package:cctv_calculator/widgets/camera_group_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Instancia de nuestro cerebro
  final CalculatorService _calculatorService = CalculatorService();
  final StorageService _storageService = StorageService();

  final TextEditingController _diskSizeController = TextEditingController();

  // 2. Estado (los datos que cambian)
  double _diskSizeTB = 1.0;
  final List<CameraGroup> _cameraGroups = [CameraGroup()]; // Empezamos con un grupo de cámaras
  Map<String, double> _results = {};

  bool _isLoading = true; // Para mostrar un spinner mientras carga el JSON

  // 3. Inicialización
  @override
  void initState() {
    super.initState();
  
    // 1. Inicializa los controladores PRIMERO
    _diskSizeController.text = _diskSizeTB.toString();
  
    // 2. Llama a _loadData, y CUANDO TERMINE (usando .then),
    //    ejecuta el cálculo inicial.
    _loadData().then((_) {
      // Esto se ejecuta DESPUÉS de que _loadData termina
      // y _isLoading se ha puesto en false.
      _calculate();
    });
  }

  @override
  void dispose() {
    // Limpia los controladores cuando la pantalla se cierre
    _diskSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _calculatorService.loadBitrateData();
    setState(() {
      _isLoading = false;
    });
  }

  // 4. Función de UI para calcular
  void _calculate() {
    // Escondemos el teclado si está abierto
    FocusScope.of(context).unfocus(); 

    // --- REEMPLAZA TU FUNCIÓN CON ESTO ---
    
    // Primero, leemos los valores de los TextFields y los guardamos en el estado
    // Usamos double.tryParse para evitar errores si el campo está vacío o mal escrito
    setState(() {
      _diskSizeTB = double.tryParse(_diskSizeController.text) ?? 1.0;
    });

    // --- REVISIÓN DE VALIDEZ ---
    // Verificamos si *alguna* de las tarjetas tiene una combinación inválida
    final bool hasInvalidGroup = _cameraGroups.any((group) {
      final bitrate = _calculatorService.getBitrate(
        codec: group.codec,
        resolution: group.resolution,
        fps: group.fps,
      );
      return bitrate == null; // Si es null, es inválida
    });

    // Si hay una inválida, limpiamos resultados y salimos
    if (hasInvalidGroup) {
      setState(() {
        _results = {}; // Limpia los resultados para no confundir
      });
      return; // No calcules nada
    }
    // ----------------------------

    final results = _calculatorService.calculateStorage(
      cameraGroups: _cameraGroups,
      diskSizeTB: _diskSizeTB,
    );
    
    // Actualizamos la UI con los resultados
    setState(() {
      _results = results;
    });
    // ---------------------------------
  }

  // ... (justo después de que termine la función _calculate() )

  // --- FUNCIÓN PARA GUARDAR EL PROYECTO ---
  Future<void> _saveProject() async {
    // Primero, actualizamos el _diskSizeTB desde el controlador
    setState(() {
      _diskSizeTB = double.tryParse(_diskSizeController.text) ?? 1.0;
    });

    await _storageService.saveProject(
      cameraGroups: _cameraGroups,
      diskSizeTB: _diskSizeTB,
    );

    // Muestra una confirmación
    if (mounted) { // mounted es un check de seguridad de Flutter
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Proyecto guardado!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --- FUNCIÓN PARA CARGAR EL PROYECTO ---
  Future<void> _loadProject() async {
    final data = await _storageService.loadProject();

    if (data == null) {
      // No hay nada que cargar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay ningún proyecto guardado.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // ¡Encontramos datos! Actualizamos el estado de la app
    setState(() {
      // 1. Actualiza los valores de estado
      _diskSizeTB = data['diskSizeTB'] as double;
      _cameraGroups.clear(); // Limpia la lista actual
      _cameraGroups.addAll(data['cameraGroups'] as List<CameraGroup>);

      // 2. Sincroniza los controladores de texto
      _diskSizeController.text = _diskSizeTB.toString();
      // (Los controladores de las tarjetas se crearán solos)
    });

    // 3. Recalcula todo con los nuevos datos
    _calculate();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Proyecto cargado!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // 5. La Interfaz Gráfica
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora CCTV'),
        // --- AÑADE ESTAS LÍNEAS ---
        actions: [
          // Botón de Cargar
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Cargar Proyecto',
            onPressed: _loadProject,
          ),
          // Botón de Guardar
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar Proyecto',
            onPressed: _saveProject,
          ),
        ],
        // ---------------------------
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Muestra spinner si está cargando
          : SingleChildScrollView( // Para que podamos hacer scroll
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- SECCIÓN DE PARÁMETROS GLOBALES (COLAPSABLE) ---
                  ExpansionTile(
                    title: Text('Parámetros Globales', style: Theme.of(context).textTheme.titleLarge),
                    initiallyExpanded: true, // Para que empiece abierto
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _diskSizeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Tamaño del Disco (TB)',
                                border: OutlineInputBorder(),
                              ),

                              onChanged: (_) => _calculate(), // Recalcula al cambiar
                              
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  // --- FIN DE PARÁMETROS GLOBALES ---

                  // --- SECCIÓN DE CÁMARAS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Grupos de Cámaras', style: Theme.of(context).textTheme.titleLarge),
                      // Botón para añadir más grupos
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            // Añade un nuevo grupo vacío a la lista
                            _cameraGroups.add(CameraGroup());
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
     
                  // Aquí construimos la lista de grupos de cámaras
                  ListView.builder(
                    itemCount: _cameraGroups.length,
                    shrinkWrap: true, // Importante para anidar un ListView en un SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll de la lista interna
                    itemBuilder: (context, index) {
                      final group = _cameraGroups[index]; // Obtenemos el grupo actual

                      // --- LÓGICA DE CÁLCULO POR TARJETA ---
                      final int? bitrate = _calculatorService.getBitrate(
                        codec: group.codec,
                        resolution: group.resolution,
                        fps: group.fps,
                      );

                      final bool isValid = bitrate != null;
  
                      // Calculamos el consumo DIARIO solo para este grupo
                      double gbPerDayGroup = 0;
                      if (isValid) {
                        // Usamos la misma fórmula, pero multiplicada por la cantidad de este grupo
                        gbPerDayGroup = (bitrate * 0.0108) * group.quantity;
                      }
                      // ------------------------------------

                      return CameraGroupCard(
                        cameraGroup: _cameraGroups[index],
                        codecOptions: _calculatorService.codecOptions,
                        resolutionOptions: _calculatorService.resolutionOptions,
                        fpsOptions: _calculatorService.fpsOptions,
                        isCombinationValid: isValid,
                        bitrate: bitrate,         // <-- PASO 1: Enviar Bitrate
                        gbPerDay: gbPerDayGroup,  // <-- PASO 2: Enviar Consumo

                        // Callback cuando se actualiza un valor
                        onUpdate: (updatedGroup) {
                          setState(() {
                            _cameraGroups[index] = updatedGroup;
                            _calculate(); // Recalcula automáticamente al cambiar
                          });
                        },
                        // Callback cuando se presiona borrar
                        onDelete: () {
                          setState(() {
                            // No permitas borrar el último grupo
                            if (_cameraGroups.length > 1) {
                              _cameraGroups.removeAt(index);
                              _calculate(); // Recalcula automáticamente al borrar
                            }
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),

                  // --- BOTÓN DE CALCULAR ---
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18)
                    ),
                    child: const Text('Calcular'),
                  ),
                  
                  const SizedBox(height: 24),

                  // --- SECCIÓN DE RESULTADOS (COLAPSABLE) ---
                  if (_results.isNotEmpty) ...[
                    ExpansionTile(
                      title: Text('Resultados', style: Theme.of(context).textTheme.titleLarge),
                      initiallyExpanded: true, // Para que empiece abierto
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Card( // La tarjeta que ya tenías
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Consumo Total (Peor Caso): ${_results['totalGbPerDay']?.toStringAsFixed(2)} GB/Día'),
                                  const SizedBox(height: 8),
                                  Text('Días Grabación (Peor Caso): ${_results['worstCaseDays']?.toStringAsFixed(1)} días'),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  Text('Días Grabación (Promedio):', style: Theme.of(context).textTheme.titleMedium),
                                  Text('${_results['averageCaseDays']?.toStringAsFixed(1)} días',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // --- FIN DE RESULTADOS ---
                ],
              ),
            ),
    );
  }
}