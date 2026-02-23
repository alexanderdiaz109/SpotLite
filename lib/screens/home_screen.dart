import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import 'project_detail_screen.dart';
import 'profile_screen.dart';
import 'ranking_screen.dart'; // Asegúrate de tener este archivo creado
import '../widgets/project_skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. ÍNDICE PARA LA NAVEGACIÓN (0: Ranking, 1: Home)
  int _currentIndex = 1;

  late Future<List<Project>> _projectsFuture;
  String _selectedFilter = "Todos";
  String _userInitials = "";

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshProjects();
    _loadUserInitials();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _refreshProjects() async {
    setState(() {
      _projectsFuture = ApiService.getProjects();
    });
    await _projectsFuture;
  }

  void _loadUserInitials() async {
    final prefs = await SharedPreferences.getInstance();
    String fullName = prefs.getString('userName') ?? "";
    if (fullName.isNotEmpty) {
      List<String> nameParts = fullName.trim().split(" ");
      String initials = nameParts[0][0].toUpperCase();
      if (nameParts.length > 1) {
        initials += nameParts[nameParts.length - 1][0].toUpperCase();
      }
      setState(() => _userInitials = initials);
    }
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    ).then((_) => _loadUserInitials());
  }

  // 2. LÓGICA DE NAVEGACIÓN CORREGIDA
  void _onItemTapped(int index) {
    if (index == 2) {
      _goToProfile(); // El perfil sigue siendo una pantalla aparte
    } else {
      setState(() {
        _currentIndex = index; // Cambia entre Ranking (0) y Home (1)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      // 3. USAMOS INDEXEDSTACK PARA CAMBIAR DE PANTALLA
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const RankingScreen(), // Pantalla 0: Ranking
          _buildHomeContent(), // Pantalla 1: El Home con diseño espacial
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          color: const Color(0xFF020617).withOpacity(0.9),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF2D8CFF),
          unselectedItemColor: Colors.grey.shade600,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          currentIndex: _currentIndex > 1 ? 1 : _currentIndex,
          // 4. CONECTAMOS EL TAP
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET CON EL DISEÑO DEL HOME (Extraído para limpieza)
  Widget _buildHomeContent() {
    return Stack(
      children: [
        // Fondos Atmosféricos
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A00E0).withOpacity(0.4),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2D8CFF).withOpacity(0.3),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!_isSearching)
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "SpotLight",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      )
                    else
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Buscar proyecto...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF2D8CFF),
                            ),
                          ),
                        ),
                      ),

                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isSearching ? Icons.close : Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isSearching) _searchController.clear();
                              _isSearching = !_isSearching;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _goToProfile,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2D8CFF).withOpacity(0.8),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2D8CFF,
                                  ).withOpacity(0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF1A254F),
                              child: Text(
                                _userInitials.isEmpty ? "?" : _userInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                child: Text(
                  "Explora Proyectos",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    _buildFilterChip("Todos"),
                    _buildFilterChip("Móvil"),
                    _buildFilterChip("Web"),
                    _buildFilterChip("Web y Móvil"),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: FutureBuilder<List<Project>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: 3,
                        itemBuilder: (context, index) =>
                            const ProjectSkeleton(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refreshProjects,
                        child: ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                "No hay proyectos disponibles.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final projects = snapshot.data!;
                    final filteredProjects = _selectedFilter == "Todos"
                        ? projects
                        : projects.where((p) {
                            final techs = p.tecnologias
                                .map((t) => t.toLowerCase())
                                .toList();
                            bool esMovil = techs.any(
                              (t) =>
                                  t.contains("móvil") ||
                                  t.contains("movil") ||
                                  t.contains("mobile"),
                            );
                            bool esWeb = techs.any((t) => t.contains("web"));
                            bool esHibrido =
                                techs.contains("web y móvil") ||
                                (esMovil && esWeb);

                            if (_selectedFilter == "Móvil")
                              return esMovil &&
                                  !esWeb &&
                                  !techs.contains("web y móvil");
                            if (_selectedFilter == "Web")
                              return esWeb &&
                                  !esMovil &&
                                  !techs.contains("web y móvil");
                            if (_selectedFilter == "Web y Móvil")
                              return esHibrido;
                            return false;
                          }).toList();

                    final searchResults = filteredProjects.where((p) {
                      final query = _searchController.text.toLowerCase();
                      return p.title.toLowerCase().contains(query) ||
                          p.description.toLowerCase().contains(query) ||
                          p.equipoNumero.toString().contains(query);
                    }).toList();

                    if (searchResults.isEmpty) {
                      return const Center(
                        child: Text(
                          "No hay coincidencias",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshProjects,
                      color: const Color(0xFF2D8CFF),
                      backgroundColor: const Color(0xFF131B38),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildProjectCard(searchResults[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2D8CFF)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2D8CFF)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final imageProvider = (project.imageUrl.isNotEmpty)
        ? NetworkImage(project.imageUrl)
        : const NetworkImage("https://picsum.photos/seed/tech/800/400");

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(project: project),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: const Color(0xFF131B38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'project-img-${project.id}',
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D8CFF),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_alt_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "EQUIPO ${project.equipoNumero}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D8CFF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          project.tecnologias.any(
                                (t) => t.toLowerCase().contains('móvil'),
                              )
                              ? Icons.phone_android
                              : Icons.web,
                          color: const Color(0xFF2D8CFF),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.tecnologias
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                color: Color(0xFF2D8CFF),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    project.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.9),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Text(
                      "Visualizar Proyecto",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
