import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import 'project_detail_screen.dart';
import 'profile_screen.dart';
import 'ranking_screen.dart'; // Asegúrate de tener este archivo creado
import '../widgets/project_skeleton.dart';
import '../utils/image_utils.dart';

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
  String _selectedCategory = "Todas"; // Nuevo filtro de categoría
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF8FAFC),
      // 3. USAMOS INDEXEDSTACK PARA CAMBIAR DE PANTALLA
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const RankingScreen(), // Pantalla 0: Ranking
          _buildHomeContent(isDark), // Pantalla 1: El Home con diseño espacial
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          color: isDark
              ? const Color(0xFF020617).withOpacity(0.9)
              : Colors.white.withOpacity(0.95),
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
  Widget _buildHomeContent(bool isDark) {
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
                          Text(
                            "SpotLight",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF050B30),
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
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: "Buscar proyecto...",
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5),
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF050B30),
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

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                child: Text(
                  "Explora proyectos",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF050B30),
                  ),
                ),
              ),


              // 2. FILTRO DE CATEGORÍA (Nuevo)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    _buildFilterChip("Todas", isDark, isCategory: true),
                    _buildFilterChip("Proyectos", isDark, isCategory: true),
                    _buildFilterChip("Juegos", isDark, isCategory: true),
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
                          children: [
                            const SizedBox(height: 100),
                            Center(
                              child: Text(
                                "No hay proyectos disponibles.",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final projects = snapshot.data!;
                    
                    // Filtrado de Categoría
                    final filteredProjects = projects.where((p) {
                      if (_selectedCategory == "Todas") {
                        return true;
                      }
                      return p.category.toLowerCase() == _selectedCategory.toLowerCase();
                    }).toList();

                    final searchResults = filteredProjects.where((p) {
                      final query = _searchController.text.toLowerCase();
                      return p.title.toLowerCase().contains(query) ||
                          p.description.toLowerCase().contains(query) ||
                          p.equipoNumero.toString().contains(query);
                    }).toList();

                    if (searchResults.isEmpty) {
                      return Center(
                        child: Text(
                          "No hay coincidencias",
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      );
                    }

                    // SEPARAR ELEMENTOS EN DOS LISTAS: JUEGOS Y PROYECTOS
                    final listaJuegos = searchResults.where((p) => p.category.toLowerCase() == 'juegos').toList();
                    final listaProyectos = searchResults.where((p) => p.category.toLowerCase() != 'juegos').toList();

                    return RefreshIndicator(
                      onRefresh: _refreshProjects,
                      color: const Color(0xFF2D8CFF),
                      backgroundColor: isDark
                          ? const Color(0xFF131B38)
                          : Colors.white,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        children: [
                          if (listaJuegos.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15, top: 10),
                              child: Text(
                                "🎮 Juegos",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF050B30),
                                ),
                              ),
                            ),
                            ...listaJuegos.map((project) => _ProjectPreviewCard(
                                  project: project,
                                  isDark: isDark,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProjectDetailScreen(
                                        project: project,
                                      ),
                                    ),
                                  ).then((_) => _refreshProjects()),
                                )),
                          ],
                          
                          if (listaProyectos.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15, top: 15),
                              child: Text(
                                "🚀 Proyectos",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF050B30),
                                ),
                              ),
                            ),
                            ...listaProyectos.map((project) => _ProjectPreviewCard(
                                  project: project,
                                  isDark: isDark,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProjectDetailScreen(
                                        project: project,
                                      ),
                                    ),
                                  ).then((_) => _refreshProjects()),
                                )),
                          ],
                        ],
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

  Widget _buildFilterChip(String label, bool isDark, {required bool isCategory}) {
    bool isSelected = isCategory ? _selectedCategory == label : _selectedFilter == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isCategory) {
            _selectedCategory = label;
          } else {
            _selectedFilter = label;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2D8CFF)
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2D8CFF)
                : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

}

class _ProjectPreviewCard extends StatefulWidget {
  final Project project;
  final bool isDark;
  final VoidCallback onTap;

  const _ProjectPreviewCard({
    required this.project,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ProjectPreviewCard> createState() => _ProjectPreviewCardState();
}

class _ProjectPreviewCardState extends State<_ProjectPreviewCard> {
  Timer? _visibilityTimer;
  bool _isPlayingPreview = false;
  bool _hasPlayed = false;
  
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.6) {
      if (!_hasPlayed && !_isPlayingPreview && _visibilityTimer == null) {
        _visibilityTimer = Timer(const Duration(seconds: 3), _initializeVideo);
      }
    } else {
      if (_chewieController != null && _chewieController!.isFullScreen) {
        return; // Don't stop video if it was covered by its own fullscreen route
      }
      _visibilityTimer?.cancel();
      _visibilityTimer = null;
      if (_isPlayingPreview) {
         _stopVideo();
         _hasPlayed = true;
      } else if (_hasPlayed && info.visibleFraction == 0) {
         _hasPlayed = false;
      }
    }
  }

  Future<void> _initializeVideo() async {
    final videoUrl = widget.project.previewVideoUrl.trim();
    if (videoUrl.isEmpty) return;

    setState(() {
      _isPlayingPreview = true;
    });

    try {
      if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
        final yt = YoutubeExplode();
        String processedUrl = videoUrl;
        if (processedUrl.contains('/shorts/')) {
          final RegExp shortRegex = RegExp(r'/shorts/([a-zA-Z0-9_-]+)');
          final match = shortRegex.firstMatch(processedUrl);
          if (match != null) {
            processedUrl = 'https://www.youtube.com/watch?v=${match.group(1)}';
          }
        }
        final manifest = await yt.videos.streamsClient.getManifest(processedUrl);
        final streamInfo = manifest.muxed.withHighestBitrate();
        _videoController = VideoPlayerController.networkUrl(streamInfo.url);
        await _videoController!.initialize();
        yt.close();
      } else if (videoUrl.contains('drive.google.com')) {
        String directUrl = videoUrl;
        String? videoId;
        final RegExp driveRegex = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
        final match = driveRegex.firstMatch(videoUrl);
        if (match != null && match.groupCount >= 1) {
          videoId = match.group(1);
        } else {
          final uri = Uri.tryParse(videoUrl);
          if (uri != null && uri.queryParameters.containsKey('id')) {
            videoId = uri.queryParameters['id'];
          }
        }
        if (videoId != null) {
          directUrl = 'https://drive.google.com/uc?export=download&id=$videoId';
        }
        _videoController = VideoPlayerController.networkUrl(Uri.parse(directUrl));
        await _videoController!.initialize();
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await _videoController!.initialize();
      }

      await _videoController!.setVolume(1.0); // Con sonido por solicitud si va a tener controles
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: true, // Mostrar controles
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: Container(color: Colors.black),
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );

      _videoController!.addListener(_videoListener);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error loading preview: $e");
      _stopVideo();
    }
  }

  void _videoListener() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      if (_videoController!.value.position >= _videoController!.value.duration) {
        _stopVideo();
        _hasPlayed = true; 
      }
    }
  }

  void _stopVideo() {
    _visibilityTimer?.cancel();
    _visibilityTimer = null;
    _videoController?.removeListener(_videoListener);
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    
    if (mounted) {
      setState(() {
        _isPlayingPreview = false;
      });
    }
  }

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validImageUrl = ImageUtils.getValidImageUrl(widget.project.imageUrl);
    final imageProvider = (validImageUrl.isNotEmpty)
        ? NetworkImage(validImageUrl)
        : const NetworkImage("https://picsum.photos/seed/tech/800/400");

    final allTechs = widget.project.tecnologias;
    final platformsList = ["Web", "Móvil", "Web y Móvil", "Movil"];
    List<String> pureTechs = [];
    String displayPlatform = "Desconocido";

    if (allTechs.isNotEmpty && platformsList.contains(allTechs.first)) {
      displayPlatform = allTechs.first;
      pureTechs = allTechs.sublist(1);
    } else {
      pureTechs = List.from(allTechs);
      if (allTechs.any((t) => t.toLowerCase().contains('móvil') || t.toLowerCase().contains('movil'))) {
        displayPlatform = "Móvil";
      } else {
        displayPlatform = "Web";
      }
    }

    return VisibilityDetector(
      key: Key('project-vis-${widget.project.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF131B38) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'project-img-${widget.project.id}',
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    image: _isPlayingPreview && _chewieController != null 
                           ? null 
                           : DecorationImage(
                               image: imageProvider,
                               fit: BoxFit.cover,
                             ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        if (_isPlayingPreview && _chewieController != null)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black, // Fondo negro para evitar espacios blancos
                              child: Chewie(controller: _chewieController!),
                            ),
                          ),
                        if (!_isPlayingPreview || _chewieController == null)
                          Container(
                            decoration: BoxDecoration(
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
                        if (!_isPlayingPreview || _chewieController == null)
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
                                    "EQUIPO ${widget.project.equipoNumero}",
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
                            widget.project.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark ? Colors.white : Colors.black87,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D8CFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                displayPlatform.toLowerCase().contains('móvil') || displayPlatform.toLowerCase().contains('movil')
                                    ? Icons.phone_android
                                    : Icons.web,
                                color: const Color(0xFF2D8CFF),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                displayPlatform,
                                style: const TextStyle(
                                  color: Color(0xFF2D8CFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pureTechs
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : const Color(0xFF2D8CFF).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: widget.isDark
                                      ? Colors.white10
                                      : const Color(0xFF2D8CFF).withOpacity(0.2),
                                ),
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
                      widget.project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black54,
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
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.9)
                              : const Color(0xFF2D8CFF),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.15)
                                : const Color(0xFF2D8CFF).withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        "Visualizar proyecto",
                        style: TextStyle(
                          color: widget.isDark ? Colors.white : const Color(0xFF2D8CFF),
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
      ),
    );
  }
}
