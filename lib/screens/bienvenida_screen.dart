import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.getCurrentUser();
    
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/fondo_bienvenidos.png',
              fit: BoxFit.cover,
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Botón de cerrar sesión en la esquina superior derecha
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      onPressed: () async {
                        // Cerrar sesión de Google si está activa
                        try {
                          await GoogleSignIn().signOut();
                        } catch (e) {
                          print('Error al cerrar sesión de Google: $e');
                        }
                        
                        // Limpiar usuario actual
                        UserService.clearCurrentUser();
                        
                        // Navegar a la pantalla de login
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.3),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                // Logo
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Image.asset(
                      'assets/icons/logo_color.png',
                      width: 250,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                // Mensaje de bienvenida - Imagen
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Image.asset(
                      'assets/bienvenidos.png',
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Subtítulo
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Text(
                      'Ya estás listo para disfrutar\nde la experiencia Certiva',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Botón Ir a inicio
                Center(
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar a la pantalla principal
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB47EDB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ir a inicio',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 