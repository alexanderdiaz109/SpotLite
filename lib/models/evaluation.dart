class Evaluation {
  final String projectId;
  final String evaluatorId;
  final int innovacion;
  final int funcionalidad;
  final int disenoUx;
  final int impacto;
  final String resenaTexto;

  Evaluation({
    required this.projectId,
    required this.evaluatorId,
    required this.innovacion,
    required this.funcionalidad,
    required this.disenoUx,
    required this.impacto,
    required this.resenaTexto,
  });

  Map<String, dynamic> toJson() {
    return {
      "projectId": projectId,
      "evaluatorId": evaluatorId,
      "scores": {
        "innovacion": innovacion,
        "funcionalidad": funcionalidad,
        "diseno_ux": disenoUx,
        "impacto": impacto,
      },
      "resena_texto": resenaTexto,
    };
  }
}
