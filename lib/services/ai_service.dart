import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Sistema de logs locales para guardar lo que responde Gemini fuera de la base de datos
  static Future<void> _saveLogLocal(
    String projectName,
    String reviewText,
    Map<String, dynamic> aiResponse,
  ) async {
    try {
      // Guardar de forma robusta en AppDocuments o la raíz usando path_provider real
      final directory = await getApplicationDocumentsDirectory();
      String path = '\${directory.path}/SpotLight_AILogs.json';
      File file = File(path);

      List<dynamic> logs = [];

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          try {
            logs = json.decode(content);
          } catch (_) {}
        }
      }

      logs.add({
        "fecha": DateTime.now().toIso8601String(),
        "proyecto": projectName,
        "resenaOriginal": reviewText,
        "respuestaIA": aiResponse,
      });

      final encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(logs));
      print('✅ LOG GUARDADO EN: \$path');
    } catch (e) {
      print('❌ Error al guardar log local: \$e');

      // Fallback extremo si falla path_provider (Entorno Windows Dev)
      try {
        File fallbackFile = File('SpotLight_AILogs.json');
        if (!await fallbackFile.exists()) {
          await fallbackFile.writeAsString("[]");
        }
        final content = await fallbackFile.readAsString();
        List<dynamic> logs = json.decode(content);
        logs.add({
          "fecha": DateTime.now().toIso8601String(),
          "proyecto": projectName,
          "resenaOriginal": reviewText,
          "respuestaIA": aiResponse,
        });
        await fallbackFile.writeAsString(
          JsonEncoder.withIndent('  ').convert(logs),
        );
        print(
          '✅ LOG GUARDADO EN LA RAIZ DEL PROYECTO: \${fallbackFile.absolute.path}',
        );
      } catch (e2) {
        print('❌ Fallo total al guardar log: \$e2');
      }
    }
  }

  static Future<Map<String, dynamic>?> analyzeReview(
    String projectName,
    String reviewText,
  ) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: "application/json",
        ),
      );

      final prompt = '''
      Actúa como un juez experto en innovación tecnológica. Evalúa el proyecto "\$projectName" basándote ÚNICAMENTE en la siguiente reseña: "\$reviewText".
        
      Devuelve un JSON EXACTAMENTE con esta estructura:
      {
        "innovacion": 4,
        "funcionalidad": 5,
        "disenoUx": 4,
        "impacto": 3,
        "aiAnalysis": {
          "analisis": "El proyecto tiene un gran potencial pero...",
          "puntuacionFactibilidad": 85,
          "fortalezas": ["Buena idea", "Tecnología moderna"],
          "nivelRiesgo": "Bajo"
        }
      }
      
      Reglas MUY ESTRICTAS:
      1. Las calificaciones (innovacion, funcionalidad, disenoUx, impacto) deben ser enteros de 0 a 5.
      2. "analisis" DEBE contener un pequeño párrafo de texto (1-3 líneas) con tu opinión explicativa sobre la viabilidad. NO DEBE ESTAR VACÍO NUNCA.
      3. "puntuacionFactibilidad" DEBE ser un entero del 0 al 100 evaluando la viabilidad comercial y técnica. OBLIGATORIO.
      4. "fortalezas" debe ser un arreglo de máximo 3 strings cortos.
      5. "nivelRiesgo" debe ser estrictamente "Alto", "Medio" o "Bajo".
      6. RESPETA ESTRICTAMENTE EL FORMATO JSON MOSTRADO. Invéntate valores neutrales o genéricos si la reseña del usuario carece de información útil.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        final Map<String, dynamic> responseData = json.decode(response.text!);

        // Guardamos el log inmediatamente después de recibir respuesta
        await _saveLogLocal(projectName, reviewText, responseData);

        return responseData;
      }
      return null;
    } catch (e) {
      print("Error en Gemini: \$e");
      return null;
    }
  }
}
