import 'dart:ui'; // Necesario para el efecto vidrio
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _specialtyController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    // 1. Validaciones
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passController.text.isEmpty ||
        _specialtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseñas no coinciden"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Objeto User con datos reales
    final newUser = User(
      nombreCompleto: _nameController.text,
      correoInstitucional: _emailController.text,
      password: _passController.text,
      areaEspecialidad: _specialtyController.text,
      rol: "evaluador",
      statusVerificacion: true,
    );

    // 3. Envío al servidor
    bool success = await ApiService.register(newUser);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Registro exitoso! Inicia sesión.")),
        );
        Navigator.pop(context); // Regresa al Login
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Error al registrar (El correo ya existe o falló la red)",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el mismo fondo degradado que en el Login
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  Color(0xFF4A00E0),
                  Color(0xFF050B30),
                  Color(0xFF020617),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.05,
                        ), // Fondo oscuro translúcido
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Crear Cuenta",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Únete a SpotLight",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // INPUTS ESTILO GLASS (Aquí el texto blanco sí se verá)
                          _buildGlassTextField(
                            _nameController,
                            "Nombre Completo",
                            Icons.person_outline,
                          ),
                          const SizedBox(height: 15),
                          _buildGlassTextField(
                            _emailController,
                            "Correo Institucional",
                            Icons.email_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildGlassTextField(
                            _passController,
                            "Contraseña",
                            Icons.lock_outline,
                            true,
                          ),
                          const SizedBox(height: 15),
                          _buildGlassTextField(
                            _confirmPassController,
                            "Confirmar Contraseña",
                            Icons.lock_outline,
                            true,
                          ),
                          const SizedBox(height: 15),
                          _buildGlassTextField(
                            _specialtyController,
                            "Especialidad / Carrera",
                            Icons.school_outlined,
                          ),

                          const SizedBox(height: 30),

                          // Botón Registrarse
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4A00E0,
                                  ).withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "REGISTRARSE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Volver al inicio de sesión",
                              style: TextStyle(
                                color: Color(0xFF2D8CFF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para los inputs (idéntico al del Login nuevo)
  Widget _buildGlassTextField(
    TextEditingController controller,
    String hint,
    IconData icon, [
    bool obscure = false,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        // ESTO ASEGURA QUE EL TEXTO SEA BLANCO
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
