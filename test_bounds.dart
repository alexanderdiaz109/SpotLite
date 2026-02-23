import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = "https://spotlight-api-m2kt.onrender.com/api";

  Future<void> testScores(int inv, int fun, int dis, int imp) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/Evaluations'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "projectId": "698b58d6246b1d8bd8104da3",
          "evaluatorId": "Juez_IA",
          "scores": {
            "innovacion": inv,
            "funcionalidad": fun,
            "disenoUx": dis,
            "impacto": imp,
          },
          "resenaTexto": "Test limit",
        }),
      );
      print(
        'Tested \${inv}, \${fun}, \${dis}, \${imp} -> Status: \${response.statusCode}',
      );
      if (response.statusCode != 201) print('Body: \${response.body}');
    } catch (e) {
      print('Error caught: \$e');
    }
  }

  await testScores(10, 10, 10, 10);
  await testScores(20, 40, 20, 20);
  await testScores(5, 5, 5, 5);
}
