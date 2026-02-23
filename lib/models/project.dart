class Project {
  final String id;
  final int equipoNumero;
  final String title;
  final String description;
  final String category;
  final String videoUrl;
  final String imageUrl;
  final String metodologia;
  final List<String> tecnologias;
  final List<String> members; // 👈 ESTE CAMPO ES NECESARIO
  final ProjectStats stats;

  Project({
    required this.id,
    required this.equipoNumero,
    required this.title,
    required this.description,
    required this.category,
    required this.videoUrl,
    required this.imageUrl,
    required this.metodologia,
    required this.tecnologias,
    required this.members,
    required this.stats,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] is Map
          ? json['_id']['\$oid'] ?? ''
          : json['id'] ?? json['_id'] ?? '',
      equipoNumero: json['equipoNumero'] ?? json['equipo_numero'] ?? 0,
      title: json['title'] ?? 'Sin Título',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      videoUrl: json['videoUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      metodologia: json['metodologia'] ?? 'No especificada',

      tecnologias: (json['technologies'] != null)
          ? List<String>.from(json['technologies'])
          : (json['tecnologias'] != null)
          ? List<String>.from(json['tecnologias'])
          : [],

      // 👇 RECUPERACIÓN DE MIEMBROS
      members: json['members'] != null
          ? List<String>.from(json['members'])
          : [],

      stats: json['stats'] != null
          ? ProjectStats.fromJson(json['stats'])
          : ProjectStats(factibilidad: 0, totalEvaluaciones: 0),
    );
  }
}

class ProjectStats {
  final num factibilidad;
  final int totalEvaluaciones;

  ProjectStats({required this.factibilidad, required this.totalEvaluaciones});

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      factibilidad:
          json['puntuacionFactibilidad'] ??
          json['puntuacion_factibilidad'] ??
          0,
      totalEvaluaciones: json['totalEvaluaciones'] ?? 0,
    );
  }
}
