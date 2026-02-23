import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/project.dart';
import '../models/evaluation.dart';
import '../services/api_service.dart';
import 'rubric_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.project.videoUrl),
      );
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return const Center(
            child: Text(
              "Error al cargar video",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
      setState(() => _isVideoInitialized = true);
    } catch (e) {
      print("Error video: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final imageProvider = (widget.project.imageUrl.isNotEmpty)
        ? NetworkImage(widget.project.imageUrl)
        : const NetworkImage("https://picsum.photos/seed/tech/800/400");

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF050B30)
          : const Color(0xFF2D8CFF),
      body: CustomScrollView(
        slivers: [
          // 1. PORTADA DESLIZANTE CON EFECTO HERO
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: isDark
                ? const Color(0xFF050B30)
                : const Color(0xFF2D8CFF),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.project.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Hero(
                tag: 'project-img-${widget.project.id}', // Conexión con Home
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
          ),

          // 2. CONTENIDO DEL PROYECTO
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2746)
                    : const Color(0xFFF2F2F2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VIDEO
                    const Text(
                      "EVIDENCIA",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _isVideoInitialized
                            ? Chewie(controller: _chewieController!)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ESTADÍSTICAS
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _fetchAndShowScores,
                            child: _buildStatCard(
                              Icons.analytics,
                              "${widget.project.stats.factibilidad}%",
                              "Factibilidad",
                              isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            Icons.how_to_vote,
                            "${widget.project.stats.totalEvaluaciones}",
                            "Votos",
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // TECNOLOGÍAS
                    const Text(
                      "TECNOLOGÍAS",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.project.tecnologias
                          .map((tech) => _buildTechChip(tech, isDark))
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // INTEGRANTES
                    const Text(
                      "EQUIPO",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.project.members.isNotEmpty
                            ? widget.project.members
                                  .map((m) => _buildMemberAvatar(m))
                                  .toList()
                            : [
                                const Text(
                                  "Sin integrantes",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DESCRIPCIÓN Y METODOLOGÍA
                    _buildSectionTitle("Proyecto Abstracto", isDark),
                    Text(
                      widget.project.description,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 15),
                    _buildSectionTitle("Metodología", isDark),
                    Text(
                      widget.project.metodologia,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN CALIFICAR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RubricScreen(project: widget.project),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D8CFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(
                          Icons.rate_review,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Calificar Proyecto",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label, bool isDark) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF2D8CFF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark
              ? const Color(0xFF2D8CFF).withOpacity(0.5)
              : const Color(0xFFE3F2FD),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF050B30),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2D8CFF), size: 28),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF2D8CFF),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name.split(" ")[0],
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS PARA MODAL DE CALIFICACIONES ---

  Future<void> _fetchAndShowScores() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2D8CFF)),
      ),
    );

    final List<Evaluation> evals = await ApiService.getEvaluationsByProject(
      widget.project.id,
    );

    if (!mounted) return;
    Navigator.pop(context); // Cerrar indicador de carga

    _showScoresBottomSheet(context, evals);
  }

  void _showScoresBottomSheet(BuildContext context, List<Evaluation> evals) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    double avgInnovacion = 0;
    double avgFuncionalidad = 0;
    double avgDiseno = 0;
    double avgImpacto = 0;

    if (evals.isNotEmpty) {
      for (var e in evals) {
        avgInnovacion += e.innovacion;
        avgFuncionalidad += e.funcionalidad;
        avgDiseno += e.disenoUx;
        avgImpacto += e.impacto;
      }
      avgInnovacion /= evals.length;
      avgFuncionalidad /= evals.length;
      avgDiseno /= evals.length;
      avgImpacto /= evals.length;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131B38) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D8CFF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics, color: Color(0xFF2D8CFF)),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Análisis Detallado",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF050B30),
                      ),
                    ),
                    Text(
                      evals.isEmpty
                          ? "Aún no hay evaluaciones"
                          : "Promedio de ${evals.length} evaluaciones",
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            if (evals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    "Este proyecto no tiene evaluaciones registradas todavía.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ),
              )
            else ...[
              _buildScoreRow(
                "Innovación y Originalidad",
                avgInnovacion,
                5,
                isDark,
              ),
              _buildScoreRow(
                "Funcionalidad Técnica",
                avgFuncionalidad,
                5,
                isDark,
              ),
              _buildScoreRow("Diseño y UX", avgDiseno, 5, isDark),
              _buildScoreRow("Impacto Social", avgImpacto, 5, isDark),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score, int maxScore, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                "${score.toStringAsFixed(1)} / $maxScore",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D8CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: maxScore > 0 ? (score / maxScore) : 0,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white10
                  : Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2D8CFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
