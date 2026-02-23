import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import 'project_detail_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<Project>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _refreshRanking();
  }

  Future<void> _refreshRanking() async {
    setState(() {
      _rankingFuture = ApiService.getProjects().then((projects) {
        // Ordenamos los proyectos por 'factibilidad' de forma descendente (Mayor a Menor)
        projects.sort(
          (a, b) => b.stats.factibilidad.compareTo(a.stats.factibilidad),
        );
        return projects;
      });
    });
    await _rankingFuture;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Ranking Global",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF050B30),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF050B30),
        ),
      ),
      body: FutureBuilder<List<Project>>(
        future: _rankingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D8CFF)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No hay proyectos calificados aún.",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          final List<Project> projects = snapshot.data!;
          final List<Project> top3 = projects.take(3).toList();

          return RefreshIndicator(
            onRefresh: _refreshRanking,
            color: const Color(0xFF2D8CFF),
            backgroundColor: isDark ? const Color(0xFF131B38) : Colors.white,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildPodium(top3, isDark),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildRankingTile(
                        projects[index],
                        index + 1,
                        isDark,
                      );
                    }, childCount: projects.length),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============== WIDGETS DEL PODIUM (TOP 3) ==============
  Widget _buildPodium(List<Project> top3, bool isDark) {
    if (top3.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (top3.length > 1) _buildPodiumPosition(top3[1], 2, isDark),
        if (top3.isNotEmpty) _buildPodiumPosition(top3[0], 1, isDark),
        if (top3.length > 2) _buildPodiumPosition(top3[2], 3, isDark),
      ],
    );
  }

  Widget _buildPodiumPosition(Project p, int position, bool isDark) {
    double heightAvatar = position == 1 ? 90 : 70;
    Color medalColor;

    switch (position) {
      case 1:
        medalColor = const Color(0xFFFFD700); // Oro
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0); // Plata
        break;
      case 3:
      default:
        medalColor = const Color(0xFFCD7F32); // Bronce
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: heightAvatar / 2,
                  backgroundImage: p.imageUrl.isNotEmpty
                      ? NetworkImage(p.imageUrl)
                      : const NetworkImage(
                              "https://picsum.photos/seed/tech/200/200",
                            )
                            as ImageProvider,
                  backgroundColor: isDark
                      ? const Color(0xFF131B38)
                      : Colors.grey[300],
                ),
                Positioned(
                  bottom: -15,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: medalColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF020617)
                            : const Color(0xFFF8FAFC),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      "#$position",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              "EQ ${p.equipoNumero}",
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF050B30),
                fontWeight: FontWeight.bold,
                fontSize: position == 1 ? 16 : 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2D8CFF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "${p.stats.factibilidad}%",
                style: const TextStyle(
                  color: Color(0xFF2D8CFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            if (position == 1)
              const SizedBox(height: 20)
            else
              const SizedBox(height: 10), // Offset visual
          ],
        ),
      ),
    );
  }

  // ============== WIDGETS DE LA LISTA (RESTO) ==============
  Widget _buildRankingTile(Project p, int position, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131B38) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                "#$position",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundImage: p.imageUrl.isNotEmpty
                  ? NetworkImage(p.imageUrl)
                  : const NetworkImage(
                          "https://picsum.photos/seed/tech/100/100",
                        )
                        as ImageProvider,
              backgroundColor: const Color(0xFF2D8CFF),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Equipo ${p.equipoNumero}",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2D8CFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "${p.stats.factibilidad}%",
                style: const TextStyle(
                  color: Color(0xFF2D8CFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
