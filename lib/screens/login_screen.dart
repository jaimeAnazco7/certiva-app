import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'register_screen.dart';
import 'bienvenida_screen.dart';
import 'recuperar_contrasena_screen.dart';
import '../services/user_service.dart'; // Import UserService
import '../services/client_api_service.dart'; // Import ClientApiService
import '../models/user.dart' as app_user; // Import User model with alias

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Cargar credenciales guardadas al iniciar la pantalla
  void _loadSavedCredentials() {
    final savedCredentials = UserService.getSavedLoginCredentials();
    if (savedCredentials != null) {
      setState(() {
        emailController.text = savedCredentials['email'] ?? '';
        passwordController.text = savedCredentials['password'] ?? '';
        rememberMe = true;
      });
      print('✅ [Login] Credenciales cargadas automáticamente');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final url = Uri.parse('https://kove.app.kove.com.py/ords/certiva_situs/app/autenticacion');
    final String rawAuth = '${Uri.encodeComponent('CERTIVA_APP')}:${Uri.encodeComponent('CerTiva2028*')}';
    final basicAuth = 'Basic ' + base64Encode(utf8.encode(rawAuth));

    print('URL: $url');
    print('Cuerpo: {"username": "${email}", "password": "${password}"}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      print('Código de estado: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Respuesta JSON: $responseData');
        if (responseData['status'] == 'success' && responseData['autenticado'] == true) {
          print('✅ [Login] Autenticación exitosa, sincronizando con API...');
          
          // Guardar o eliminar credenciales según el checkbox "Recordar mis datos"
          if (rememberMe) {
            await UserService.saveLoginCredentials(email, password);
            print('💾 [Login] Credenciales guardadas');
          } else {
            await UserService.clearLoginCredentials();
            print('🗑️ [Login] Credenciales eliminadas');
          }
          
          // Obtener usuario local primero como respaldo
          final app_user.User? localUser = await UserService.getUserByEmail(email);
          
          // Intentar obtener datos actualizados desde la API
          final app_user.User? apiUser = await UserService.getUserByEmailWithApiSync(email);
          
          // Usar datos de la API si están disponibles, si no usar local
          final app_user.User? user = apiUser ?? localUser ?? UserService.getCurrentUser();
          
          if (user != null) {
            print('✅ [Login] Usuario configurado: ${user.email}');
            print('✅ [Login] ID Cliente: ${user.idCliente}');
            print('✅ [Login] Fuente de datos: ${user.idCliente != null ? "API" : "HIVE"}');
            UserService.setCurrentUser(user);
          } else {
            print('⚠️ [Login] No se pudo obtener información del usuario');
          }
          
          // Navegar a la pantalla de bienvenida
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BienvenidaScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario o contraseña incorrectos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
              backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      print('🔄 [Login] Iniciando autenticación con Google (nativo)...');
      
      // Paso 1: Autenticación nativa con Google (no sale de la app)
      // Google Sign-In detecta automáticamente el Client ID basado en el package name y SHA-1
      // configurado en Google Cloud Console
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print('⚠️ [Login] Usuario canceló la autenticación');
        return; // Usuario canceló
      }
      
      print('✅ [Login] Usuario autenticado con Google: ${googleUser.email}');
      
      // Paso 2: Obtener el email del usuario de Google
      final email = googleUser.email;
      
      if (email.isEmpty) {
        throw Exception('No se pudo obtener el email de Google');
      }
      
      // Paso 3: Verificar email en la API del cliente y obtener id_cliente
      await _handleSuccessfulAuth(email);
      
    } catch (e) {
      print('❌ [Login] Error al iniciar con Google: $e');
      
      // Cerrar sesión de Google en caso de error
      try {
        await GoogleSignIn().signOut();
      } catch (signOutError) {
        print('⚠️ [Login] Error al cerrar sesión de Google: $signOutError');
      }
      
      String errorMessage = 'Error al iniciar con Google';
      if (e.toString().contains('ApiException')) {
        errorMessage = 'Error de configuración de Google Sign In. Verifique la configuración OAuth en Google Cloud Console.';
      } else {
        errorMessage = 'Error al iniciar con Google: $e';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Manejar autenticación exitosa
  Future<void> _handleSuccessfulAuth(String email) async {
    try {
      print('🔄 [Login] Paso 2: Verificando email en la base de datos del cliente...');
      
      // Verificar email en la API del cliente
      final app_user.User? userFromApi = await ClientApiService.getClientByEmail(email);
      
      if (userFromApi == null) {
        print('❌ [Login] Email no registrado en la base de datos del cliente');
        
        // Cerrar sesión de Google
        try {
          await GoogleSignIn().signOut();
        } catch (e) {
          print('⚠️ [Login] Error al cerrar sesión de Google: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este correo no está registrado. Debe registrarse primero para ingresar.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        
        return;
      }

      // Usuario encontrado en la base de datos
      print('✅ [Login] Cliente encontrado en la base de datos');
      print('✅ [Login] ID Cliente: ${userFromApi.idCliente}');
      print('✅ [Login] Nombre: ${userFromApi.nombres} ${userFromApi.apellidos}');
      
      // Guardar el usuario en Hive
      await UserService.saveUser(userFromApi);
      print('💾 [Login] Usuario guardado en Hive');
      
      // Establecer el usuario como actual
      UserService.setCurrentUser(userFromApi);
      print('✅ [Login] Usuario configurado como actual');
      
      // Navegar a la pantalla de bienvenida
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BienvenidaScreen()),
        );
      }
      
      print('✅ [Login] Proceso de autenticación con Google completado exitosamente');
    } catch (e) {
      print('❌ [Login] Error al procesar autenticación exitosa: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar autenticación: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // NO ajustar cuando aparece el teclado
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Imagen de fondo
              Positioned.fill(
                child: Image.asset(
                  'assets/Imagenes_Certiva_App-02.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Capa de color para oscurecer un poco el fondo
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              // Contenido principal con footer NO fijo
              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 40),
                            // Logo
                            Image.asset(
                              'assets/logo_blanco-removebg-preview.png',
                              width: 220,
                            ),
                            const SizedBox(height: 30),
                      // Formulario
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            // Usuario/email
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                hintText: 'Usuario - Email',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Contraseña
                            TextField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                hintText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Botón Google
                            ElevatedButton.icon(
                              onPressed: _loginWithGoogle,
                              icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                              label: const Text('Continuar con Google'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Recordar datos
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF19E2D7),
                                ),
                                const Text(
                                  'Recordar datos',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // ¿Olvidaste tu contraseña?
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RecuperarContrasenaScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Botón Iniciar sesión
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF19E2D7),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size.fromHeight(44),
                              ),
                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                          ],
                        ),
                        // Footer NO fijo (se queda abajo, el teclado lo tapa)
                        Container(
                          width: double.infinity,
                          color: Colors.grey[800]?.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '¿Aún no está registrado?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple[200],
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Registrarme',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
              ),
            ],
          );
        },
      ),
    );
  }
} 