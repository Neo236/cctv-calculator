// lib/main.dart

import 'package:flutter/material.dart';
import 'package:cctv_calculator/screens/home_screen.dart'; // Importamos la pantalla que creaste

void main() {
  // Asegura que los bindings de Flutter estén listos antes de cargar assets
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCTV Calculator',
      debugShowCheckedModeBanner: false, // Quita la cinta de "Debug"
      theme: ThemeData(
        brightness: Brightness.dark, // Tema oscuro
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, 
          brightness: Brightness.dark
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Nuestra pantalla principal
    );
  }
}