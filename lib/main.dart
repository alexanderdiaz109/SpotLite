import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';

// Definimos un ValueNotifier global para cambiar el tema desde cualquier pantalla
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? true;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  runApp(const SpotLightApp());
}

class SpotLightApp extends StatelessWidget {
  const SpotLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'SpotLight',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // 👈 Escucha el cambio de modo
          // TEMA CLARO
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFF2F2F2),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2D8CFF),
              primary: const Color(0xFF2D8CFF),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: Colors.black87,
                displayColor: Colors.black87,
              ),
            ),
          ),
          // TEMA OSCURO
          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF050B30),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2D8CFF),
              primary: const Color(0xFF2D8CFF),
              background: const Color(0xFF050B30),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
