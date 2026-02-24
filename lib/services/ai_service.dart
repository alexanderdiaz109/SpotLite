import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../api_keys.dart';

class AiService {
  static const String apiKey = ApiKeys.geminiApiKey;

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
          "puntuacionFactibilidad": 85,
          "fortalezas": ["Buena idea", "Tecnología moderna"],
          "nivelRiesgo": "Bajo"
        }
      }
      
      Reglas:
      - Las calificaciones (innovacion, funcionalidad, disenoUx, impacto) deben ser números enteros del 0 al 5.
      - "puntuacionFactibilidad" debe ser un número del 0 al 100 evaluando la viabilidad técnica/comercial.
      - "fortalezas" debe ser un arreglo de máximo 3 strings cortos.
      - "nivelRiesgo" debe ser estrictamente "Alto", "Medio" o "Bajo".
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        return json.decode(response.text!);
      }
      return null;
    } catch (e) {
      print("Error en Gemini: \$e");
      return null;
    }
  }
}
