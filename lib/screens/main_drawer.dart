import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';
import 'mis_datos_screen.dart';
import 'mis_resultados_screen.dart';
import 'quiero_consultar_screen.dart';
import 'agendar_analisis_screen.dart';
import 'mi_agenda_screen.dart';
import 'login_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.getCurrentUser();
    
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFB47EDB),
        ),
        child: Column(
          children: [
            // Header del usuario
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Row(
                children: [
                  // Avatar del usuario
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF09D5D6),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Información del usuario
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.nombres ?? 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentUser?.apellidos ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón de cerrar
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // Línea divisoria
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            // Opciones del menú
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Mis datos',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MisDatosScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.assessment,
                    title: 'Mis resultados',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MisResultadosScreen()),
                      );
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.question_answer,
                    title: 'Quiero consultar',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuieroConsultarScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_today,
                    title: 'Agendar análisis',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AgendarAnalisisScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.event_note,
                    title: 'Mi agenda',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MiAgendaScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Opción de cerrar sesión
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 24,
                ),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              ),
            ),
            // Línea divisoria antes del footer
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            // Footer con ayuda
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ayuda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
} 