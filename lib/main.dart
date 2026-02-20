import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 👈 Importar
import 'screens/login_screen.dart';

void main() {
  runApp(const SpotLightApp());
}

class SpotLightApp extends StatelessWidget {
  const SpotLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotLight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF050B30),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D8CFF),
          primary: const Color(0xFF2D8CFF),
          background: const Color(0xFF050B30),
          brightness: Brightness
              .dark, // Importante para que el texto sea blanco por defecto
        ),
        useMaterial3: true,
        // 👇 APLICAMOS POPPINS A TODA LA APP
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
