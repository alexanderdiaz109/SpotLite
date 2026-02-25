import 'package:flutter/material.dart';
import '../models/project.dart';
import 'ai_analysis_screen.dart';

class RubricScreen extends StatefulWidget {
  final Project project;
  const RubricScreen({super.key, required this.project});

  @override
  State<RubricScreen> createState() => _RubricScreenState();
}

class _RubricScreenState extends State<RubricScreen> {
  final TextEditingController _reviewController = TextEditingController();

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Escribe una reseña para que la IA analice."),
        ),
      );
      return;
    }

    // Navegar directamente a la nueva pantalla de Análisis
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiAnalysisScreen(
          project: widget.project,
          reviewText: _reviewController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF050B30)
          : const Color(0xFF2D8CFF),
      appBar: AppBar(
        // LOGO AQUÍ 👇
        title: Image.asset('assets/images/logo.png', height: 35),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2746)
                    : const Color(0xFFF2F2F2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
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
                      isDark,
                    ),
                    _buildStaticCriteria(
                      "Funcionalidad Técnica",
                      "Evalúa si el proyecto realmente funciona.",
                      "40",
                      isDark,
                    ),
                    _buildStaticCriteria(
                      "Diseño y UX",
                      "Apariencia y facilidad de uso.",
                      "20",
                      isDark,
                    ),
                    _buildStaticCriteria(
                      "Impacto Social",
                      "Utilidad en el mundo real.",
                      "20",
                      isDark,
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Reseña",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              "Describa fortalezas, debilidades y viabilidad técnica/comercial...",
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
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
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D8CFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Guardar y analizarlo",
                          style: TextStyle(
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

  Widget _buildStaticCriteria(
    String title,
    String subtitle,
    String maxScore,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
              color: isDark
                  ? const Color(0xFF2D8CFF).withOpacity(0.2)
                  : const Color(0xFFE3F2FD),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                    fontSize: 11,
                  ),
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
