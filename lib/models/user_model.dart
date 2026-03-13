class User {
  final String? id;
  final String nombreCompleto;
  final String correoInstitucional;
  final String password;
  final String rol;
  final String areaEspecialidad;
  final bool statusVerificacion;

  User({
    this.id,
    required this.nombreCompleto,
    required this.correoInstitucional,
    required this.password,
    this.rol = "evaluador",
    required this.areaEspecialidad,
    this.statusVerificacion = true,
  });

  // 👇 AQUÍ ESTABA EL ERROR: Cambiamos snake_case a PascalCase
  Map<String, dynamic> toJson() {
    return {
      "NombreCompleto": nombreCompleto, // Antes: "nombre_completo"
      "CorreoInstitucional":
          correoInstitucional, // Antes: "correo_institucional"
      "Password": password, // Antes: "password"
      "Rol": rol, // Antes: "rol"
      "AreaEspecialidad": areaEspecialidad, // Antes: "area_especialidad"
      "StatusVerificacion": statusVerificacion, // Antes: "status_verificacion"
    };
  }

  // Para recibir (dejamos flexibilidad por si acaso)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] != null ? json['_id']['\$oid'] ?? '' : '',
      // Intentamos leer ambas formas por seguridad
      nombreCompleto: json['NombreCompleto'] ?? json['nombre_completo'] ?? '',
      correoInstitucional:
          json['CorreoInstitucional'] ?? json['correo_institucional'] ?? '',
      password: '',
      rol: json['Rol'] ?? json['rol'] ?? 'evaluador',
      areaEspecialidad:
          json['AreaEspecialidad'] ?? json['area_especialidad'] ?? '',
      statusVerificacion:
          json['StatusVerificacion'] ?? json['status_verificacion'] ?? false,
    );
  }
}
