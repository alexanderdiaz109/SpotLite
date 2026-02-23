import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String apiKey = 'AIzaSyCFfIN7zkH3JRMtd5wYK1P4nLQfoqNVd6o';

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
      Actúa como un juez asistente. Evalúa el proyecto "\$projectName" basándote ÚNICAMENTE en esta reseña del evaluador: "\$reviewText".
        
        Devuelve un JSON EXACTAMENTE con esta estructura (calificaciones del 1 al 5):
        {
          "innovacion": 4,
          "funcionalidad": 5,
          "disenoUx": 4,
          "impacto": 3
        }
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
