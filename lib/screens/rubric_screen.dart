import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/evaluation.dart';
import '../services/api_service.dart';

class RubricScreen extends StatefulWidget {
  final Project project;
  const RubricScreen({super.key, required this.project});

  @override
  State<RubricScreen> createState() => _RubricScreenState();
}

class _RubricScreenState extends State<RubricScreen> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isSending = false;

  void _submitReview() async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Escribe una reseña para que la IA analice."),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final evaluation = Evaluation(
      projectId: widget.project.id,
      evaluatorId: "Juez_IA",
      innovacion: 5,
      funcionalidad: 5,
      disenoUx: 5,
      impacto: 5,
      resenaTexto: _reviewController.text,
    );

    bool success = await ApiService.sendEvaluation(evaluation);
    setState(() => _isSending = false);

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("✨ IA Analizando..."),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 10),
                Text("Generando puntajes basados en tu reseña..."),
              ],
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Evaluación Guardada")),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al enviar."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B30),
      appBar: AppBar(
        // LOGO AQUÍ 👇
        title: Image.asset('assets/images/logo.png', height: 35),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Rubrica",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStaticCriteria(
                      "Innovación y Originalidad",
                      "Evalúa si la idea es nueva.",
                      "20",
                    ),
                    _buildStaticCriteria(
                      "Funcionalidad Técnica",
                      "Evalúa si el proyecto realmente funciona.",
                      "40",
                    ),
                    _buildStaticCriteria(
                      "Diseño y UX",
                      "Apariencia y facilidad de uso.",
                      "20",
                    ),
                    _buildStaticCriteria(
                      "Impacto Social",
                      "Utilidad en el mundo real.",
                      "20",
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Reseña",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _reviewController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText:
                              "Describa fortalezas, debilidades y viabilidad técnica/comercial...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(15),
                          suffixIcon: Icon(Icons.mic, color: Color(0xFF2D8CFF)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      "Las sugerencias de IA se basarán en estas notas.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D8CFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isSending ? "Procesando..." : "Guardar y analizarlo",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticCriteria(String title, String subtitle, String maxScore) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Color(0xFF2D8CFF),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                maxScore,
                style: const TextStyle(
                  color: Color(0xFF2D8CFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                "SCORE",
                style: TextStyle(color: Colors.grey, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
