class Evaluation {
  final String projectId;
  final String evaluatorId;
  final int innovacion;
  final int funcionalidad;
  final int disenoUx;
  final int impacto;
  final String resenaTexto;
  final Map<String, dynamic>? aiAnalysis;

  Evaluation({
    required this.projectId,
    required this.evaluatorId,
    required this.innovacion,
    required this.funcionalidad,
    required this.disenoUx,
    required this.impacto,
    required this.resenaTexto,
    this.aiAnalysis,
  });

  Map<String, dynamic> toJson() {
    return {
      "projectId": projectId,
      "evaluatorId": evaluatorId,
      "scores": {
        "innovacion": innovacion,
        "funcionalidad": funcionalidad,
        "disenoUx": disenoUx,
        "impacto": impacto,
      },
      "resenaTexto": resenaTexto,
      if (aiAnalysis != null) "aiAnalysis": aiAnalysis,
    };
  }

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      projectId: json['projectId'] ?? '',
      evaluatorId: json['evaluatorId'] ?? '',
      innovacion: json['scores']?['innovacion'] ?? 0,
      funcionalidad: json['scores']?['funcionalidad'] ?? 0,
      disenoUx: json['scores']?['disenoUx'] ?? 0,
      impacto: json['scores']?['impacto'] ?? 0,
      resenaTexto: json['resenaTexto'] ?? '',
      aiAnalysis: json['aiAnalysis'],
    );
  }
}
