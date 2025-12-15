import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';
import 'main_drawer.dart';
import 'login_screen.dart';
import 'mis_datos_screen.dart';
import 'mis_resultados_screen.dart';
import 'quiero_consultar_screen.dart';
import 'mi_agenda_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.getCurrentUser();
    final userEmail = currentUser?.email ?? 'Usuario';
    // Extraer el nombre de usuario del email (parte antes del @)
    final username = userEmail.contains('@') 
        ? '@${userEmail.split('@')[0]}' 
        : userEmail;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFFB47EDB),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(
                Icons.person,
                color: Color(0xFFB47EDB),
                size: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/Imagenes Certiva App-03.png',
              fit: BoxFit.cover,
            ),
          ),
          // Contenido principal con los accesos directos
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Primera fila: Inicio y Mis datos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMenuButton(
                        context,
                        icon: 'assets/Iconos acceso directo_Mesa de trabajo 1.png',
                        label: 'Inicio',
                        onTap: () {
                          // Ya estamos en inicio, no hacer nada
                        },
                      ),
                      _buildMenuButton(
                        context,
                        icon: 'assets/Iconos acceso directo-02.png',
                        label: 'Mis datos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MisDatosScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Segunda fila: Resultados y Reserva turno
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMenuButton(
                        context,
                        icon: 'assets/Iconos acceso directo-03.png',
                        label: 'Resultados',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MisResultadosScreen()),
                          );
                        },
                      ),
                      _buildMenuButton(
                        context,
                        icon: 'assets/Iconos acceso directo-04.png',
                        label: 'Reserva turno',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QuieroConsultarScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Tercera fila: Mi agenda (centrado)
                  _buildMenuButton(
                    context,
                    icon: 'assets/Iconos acceso directo-05.png',
                    label: 'Mi agenda',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MiAgendaScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required String icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFB47EDB),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /* ======== CÓDIGO ANTERIOR COMENTADO ========
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFFB47EDB),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar',
              hintStyle: TextStyle(color: Color(0xFFB47EDB)),
              prefixIcon: Icon(Icons.search, color: Color(0xFFB47EDB)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          // Header morado extendido
          Container(
            width: double.infinity,
            height: 20,
            color: Color(0xFFB47EDB),
          ),
          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Agendá tu cita!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Lista de profesionales
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildProfessionalCard();
                      },
                    ),
                  ),
                  // Enlace inferior
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Ver listado completo',
                        style: TextStyle(
                          color: Color(0xFFB47EDB),
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar del profesional
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF09D5D6), width: 2),
            ),
            child: const Icon(
              Icons.person,
              size: 30,
              color: Color(0xFF09D5D6),
            ),
          ),
          const SizedBox(width: 16),
          // Información del profesional
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dr. David Gilmour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lunes - miércoles - viernes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF09D5D6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Clínica Médica',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Calificación (5 estrellas)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 16,
                      color: index < 4 ? Color(0xFF09D5D6) : Colors.grey[300],
                    );
                  }),
                ),
              ],
            ),
          ),
          // Botones de acción
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFB47EDB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFB47EDB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  ======== FIN CÓDIGO ANTERIOR COMENTADO ======== */
} 