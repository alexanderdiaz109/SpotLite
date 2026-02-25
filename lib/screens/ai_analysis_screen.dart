import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/evaluation.dart';
import '../services/api_service.dart';
import '../services/ai_service.dart';
import 'dart:math' as math;

class AiAnalysisScreen extends StatefulWidget {
  final Project project;
  final String reviewText;

  const AiAnalysisScreen({
    super.key,
    required this.project,
    required this.reviewText,
  });

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic>? _aiResult;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Animación de rotación infinita para la carga

    _processReview();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processReview() async {
    final aiResult = await AiService.analyzeReview(
      widget.project.title,
      widget.reviewText,
    );

    if (aiResult == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    // Preparar el envío a la API
    final evaluation = Evaluation(
      projectId: widget.project.id,
      evaluatorId: "Juez_IA", // O el ID real del usuario evaluador
      innovacion: aiResult["innovacion"] ?? 0,
      funcionalidad: aiResult["funcionalidad"] ?? 0,
      disenoUx: aiResult["disenoUx"] ?? 0,
      impacto: aiResult["impacto"] ?? 0,
      resenaTexto: widget.reviewText,
      aiAnalysis: aiResult["aiAnalysis"],
    );

    bool success = await ApiService.sendEvaluation(evaluation);

    if (mounted) {
      if (success) {
        setState(() {
          _aiResult = aiResult;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 35),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF050B30),
        ),
        // Deshabilitar botón atrás mientras carga para que no se interrumpa
        automaticallyImplyLeading: !_isLoading,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: _isLoading
              ? _buildLoadingState(isDark)
              : _hasError
              ? _buildErrorState(isDark)
              : _buildSuccessState(isDark),
        ),
      ),
    );
  }

  // ESTADO DE CARGA (Asemejando el diseño)
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (_, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * math.pi,
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFF2D8CFF).withOpacity(0.1),
                        const Color(0xFF2D8CFF),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF020617) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF2D8CFF),
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            "Analizando reseña...",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF050B30),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "La Inteligencia Artificial está procesando tus comentarios y extrayendo los puntajes.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ESTADO DE ERROR
  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
          const SizedBox(height: 25),
          Text(
            "Hubo un problema",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF050B30),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "No pudimos procesar o guardar la evaluación en este momento.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D8CFF),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Volver al Proyecto",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ESTADO DE ÉXITO (Diseño final)
  Widget _buildSuccessState(bool isDark) {
    Map<String, dynamic> aiAnalysis = _aiResult?["aiAnalysis"] ?? {};
    int viabilidad = aiAnalysis["puntuacionFactibilidad"] ?? 0;
    String nivelRiesgo = aiAnalysis["nivelRiesgo"] ?? "Desconocido";
    String opinion = aiAnalysis["analisis"] ?? "Sin opinión detallada.";
    List<dynamic> fortalezasList = aiAnalysis["fortalezas"] ?? [];
    List<String> fortalezas = fortalezasList.map((e) => e.toString()).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ICONO CENTRAL (Capas para simular degradado del mockup)
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2D8CFF).withOpacity(0.05),
                  ),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2D8CFF).withOpacity(0.15),
                      ),
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2D8CFF),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2D8CFF),
                                blurRadius: 20,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // TITULO
                Text(
                  "Reseña procesada\ncorrectamente",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF050B30),
                  ),
                ),

                const SizedBox(height: 50),

                // BARRA DE VIABILIDAD
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "PUNTUACIÓN DE VIABILIDAD",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A75A6),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        "$viabilidad%",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D8CFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: viabilidad / 100,
                    minHeight: 12,
                    backgroundColor: isDark
                        ? Colors.white10
                        : const Color(0xFFF0F4FA),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2D8CFF),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Evaluación de la arquitectura del proyecto y su adecuación al mercado",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : const Color(0xFF5A75A6),
                  ),
                ),

                const SizedBox(height: 40),

                // OPINIÓN DETALLADA
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131B38)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Análisis de la IA",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF050B30),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getRiskColor(
                                nivelRiesgo,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Riesgo: $nivelRiesgo",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getRiskColor(nivelRiesgo),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        opinion,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),

                      if (fortalezas.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          "FORTALEZAS IDENTIFICADAS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: fortalezas
                              .map(
                                (f) => Chip(
                                  label: Text(
                                    f,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: isDark
                                      ? Colors.white10
                                      : Colors.white,
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.transparent
                                        : Colors.black12,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // BOTÓN INFERIOR
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Pop back to the rubric, and pop back again to the project details
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D8CFF),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continuar evaluando",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case "bajo":
        return Colors.green;
      case "medio":
        return Colors.orange;
      case "alto":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
