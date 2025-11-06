// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cctv_calculator/models/camera_group.dart';
import 'package:cctv_calculator/services/calculator_service.dart';
import 'package:cctv_calculator/widgets/camera_group_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Instancia de nuestro cerebro
  final CalculatorService _calculatorService = CalculatorService();

  final List<String> _codecOptions = ['H.265', 'H.264'];
  final List<String> _resolutionOptions = ['1080p', '3MP', '5MP', '4K(8MP)'];
  final List<String> _fpsOptions = ['15', '25'];

  final TextEditingController _diskSizeController = TextEditingController();
  final TextEditingController _activityFactorController = TextEditingController();

  // 2. Estado (los datos que cambian)
  double _diskSizeTB = 1.0;
  double _activityFactor = 40.0; // 40%
  List<CameraGroup> _cameraGroups = [CameraGroup()]; // Empezamos con un grupo de cámaras
  Map<String, double> _results = {};

  bool _isLoading = true; // Para mostrar un spinner mientras carga el JSON

  // 3. Inicialización
  @override
  void initState() {
    super.initState();
    _loadData();

    _diskSizeController.text = _diskSizeTB.toString();
    _activityFactorController.text = _activityFactor.toString();
  }

  @override
  void dispose() {
    // Limpia los controladores cuando la pantalla se cierre
    _diskSizeController.dispose();
    _activityFactorController.dispose();
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
      _activityFactor = double.tryParse(_activityFactorController.text) ?? 40.0;
    });

    final results = _calculatorService.calculateStorage(
      cameraGroups: _cameraGroups,
      diskSizeTB: _diskSizeTB,
      activityFactorPercent: _activityFactor,
    );
    
    // Actualizamos la UI con los resultados
    setState(() {
      _results = results;
    });
    // ---------------------------------
  }

  // 5. La Interfaz Gráfica
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora CCTV'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Muestra spinner si está cargando
          : SingleChildScrollView( // Para que podamos hacer scroll
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- SECCIÓN DE PARÁMETROS GLOBALES ---
                  Text('Parámetros Globales', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _diskSizeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Tamaño del Disco (TB)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _activityFactorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Factor de Actividad (%)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

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
                      return CameraGroupCard(
                        cameraGroup: _cameraGroups[index],
                        codecOptions: _codecOptions,
                        resolutionOptions: _resolutionOptions,
                        fpsOptions: _fpsOptions,
                        // Callback cuando se actualiza un valor
                        onUpdate: (updatedGroup) {
                          setState(() {
                            _cameraGroups[index] = updatedGroup;
                          });
                        },
                        // Callback cuando se presiona borrar
                        onDelete: () {
                          setState(() {
                            // No permitas borrar el último grupo
                            if (_cameraGroups.length > 1) {
                              _cameraGroups.removeAt(index);
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

                  // --- SECCIÓN DE RESULTADOS ---
                  if (_results.isNotEmpty) ...[
                    Text('Resultados', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    
                    // Tarjeta de resultados
                    Card(
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
                  ]
                ],
              ),
            ),
    );
  }
}