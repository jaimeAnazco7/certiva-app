import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/certiva_api_service.dart';

class GenerarContrasenaScreen extends StatefulWidget {
  final User user;
  final int prepagaCode;
  const GenerarContrasenaScreen({Key? key, required this.user, required this.prepagaCode}) : super(key: key);

  @override
  State<GenerarContrasenaScreen> createState() => _GenerarContrasenaScreenState();
}

class _GenerarContrasenaScreenState extends State<GenerarContrasenaScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();
  bool showPassword = false;
  bool showRepeatPassword = false;

  @override
  void dispose() {
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  void _guardarContrasena() async {
    if (passwordController.text.isEmpty || repeatPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    if (passwordController.text != repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    // Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Registro real en backend con la contraseña definida
      final apiResult = await CertivaApiService.registrarCliente(
        email: widget.user.email,
        password: passwordController.text.trim(),
        nombre: widget.user.nombres,
        apellido: widget.user.apellidos,
        cedula: widget.user.cedula,
        prepaga: widget.prepagaCode,
        direccion: widget.user.direccion,
        telefono: widget.user.celular,
      );

      Navigator.pop(context); // cerrar loader

      if (apiResult['success'] == true) {
        // Guardar local
        final updatedUser = User(
          nombres: widget.user.nombres,
          apellidos: widget.user.apellidos,
          cedula: widget.user.cedula,
          direccion: widget.user.direccion,
          celular: widget.user.celular,
          email: widget.user.email,
          seguro: widget.user.seguro,
          password: passwordController.text,
        );
        await UserService.saveUser(updatedUser);
        UserService.setCurrentUser(updatedUser);

        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Registro Exitoso'),
              content: Text(apiResult['message'] ?? 'Usuario registrado correctamente'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      } else {
        // Error backend
        final errorMsg = apiResult['error'] ?? 'Error desconocido';
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error en el Registro'),
              content: Text(errorMsg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // cerrar loader
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error de Conexión'),
            content: Text('No se pudo conectar con el servidor: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo a color
                Image.asset(
                  'assets/icons/logo_color.png',
                  width: 180,
                ),
                const SizedBox(height: 18),
                // Título y saludo
                Text(
                  '¡Hola ${widget.user.nombres}!',
                  style: const TextStyle(
                    color: Color(0xFF09D5D6),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Favor generar contraseña',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                // Campo contraseña
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.black),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF09D5D6)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF09D5D6), width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                ),
                // Indicador de contraseña válida
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Contraseña válida',
                      style: TextStyle(
                        color: Color(0xFF09D5D6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Color(0xFFB47EDB).withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF09D5D6)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF09D5D6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Alta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Campo repetir contraseña
                TextField(
                  controller: repeatPasswordController,
                  obscureText: !showRepeatPassword,
                  decoration: InputDecoration(
                    labelText: 'Repetir contraseña',
                    labelStyle: const TextStyle(color: Colors.black),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF09D5D6)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF09D5D6), width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showRepeatPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          showRepeatPassword = !showRepeatPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Logo animado (simulado con el logo pequeño)
                Image.asset(
                  'assets/icons/logo_color.png',
                  width: 50,
                ),
                const SizedBox(height: 18),
                // Botón de registro
                Center(
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _guardarContrasena,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB47EDB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrarme',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 