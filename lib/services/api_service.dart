import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 👈 1. IMPORTANTE: Agregado para guardar sesión
import '../models/project.dart';
import '../models/evaluation.dart';
import '../models/user_model.dart';

class ApiService {
  // 👇 URL REAL DE RENDER
  static const String baseUrl = "https://spotlight-api-m2kt.onrender.com/api";

  // ==========================================
  // 1. PROYECTOS (Catálogo)
  // ==========================================
  static Future<List<Project>> getProjects() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Projects'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error cargando proyectos: $e");
      return [];
    }
  }

  // ==========================================
  // 2. EVALUACIONES (Rúbrica)
  // ==========================================
  static Future<bool> sendEvaluation(Evaluation eval) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Evaluations'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(eval.toJson()),
      );
      // 201 Created o 200 OK
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error enviando evaluación: $e");
      return false;
    }
  }

  // ==========================================
  // 3. USUARIOS (Login y Registro REALES)
  // ==========================================

  // LOGIN REAL
  static Future<bool> login(String email, String password) async {
    try {
      print("🔌 Conectando a Login para: $email");

      final response = await http.post(
        Uri.parse('$baseUrl/Users/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "correo_institucional": email,
          "password": password,
        }),
      );

      print("📩 Respuesta Login: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 👇 2. GUARDAR DATOS EN EL TELÉFONO (Para el Perfil)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data['userId'] ?? '');
        await prefs.setString('userName', data['nombre'] ?? 'Usuario');
        // Si el backend no manda rol, asumimos 'evaluador'
        await prefs.setString('userRole', data['rol'] ?? 'evaluador');
        await prefs.setString('userEmail', email);

        print("✅ Bienvenido ${data['nombre']}");
        return true;
      } else {
        print("❌ Error Login: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error de conexión Login: $e");
      return false;
    }
  }

  // REGISTRO REAL
  static Future<bool> register(User user) async {
    try {
      print("🔌 Enviando registro al servidor...");

      final response = await http.post(
        Uri.parse('$baseUrl/Users'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(user.toJson()),
      );

      print("📩 Respuesta Registro: ${response.statusCode}");

      // 201 Created o 200 OK
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Usuario creado exitosamente");
        return true;
      } else {
        print("❌ Error Registro: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error de conexión Registro: $e");
      return false;
    }
  }

  // 👇 3. FUNCIÓN LOGOUT (Faltaba esta)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra los datos guardados
  }
}
