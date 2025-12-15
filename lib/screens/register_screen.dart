import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/certiva_api_service.dart';
import 'generar_contrasena_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController seguroController = TextEditingController();

  // Opciones de prepagas (texto visible -> código a enviar)
  final List<Map<String, dynamic>> prepagasOptions = const [
    {'code': 1, 'label': 'Empresa / Corporativo'},
    {'code': 2, 'label': 'Particular'},
    {'code': 3, 'label': 'Familiar'},
    {'code': 4, 'label': 'Institucional / Convenio'},
    {'code': 5, 'label': 'Estudiantil / Joven'},
    {'code': 6, 'label': 'Senior / Jubilado'},
  ];
  int? selectedPrepagaCode;
  
  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    cedulaController.dispose();
    direccionController.dispose();
    celularController.dispose();
    emailController.dispose();
    seguroController.dispose();
    super.dispose();
  }

  void _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      // Validar que haya una prepaga seleccionada
      final prepagaCode = selectedPrepagaCode;
      if (prepagaCode == null || prepagaCode <= 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Datos inválidos'),
              content: Text('Seleccione una opción en "Seguro médico / alianzas".'),
            );
          },
        );
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // No registramos aún en el backend porque la contraseña se define en la siguiente pantalla
        // Cerramos el loader y continuamos al paso de crear contraseña
        Navigator.pop(context);

        if (mounted) {
          // Registro exitoso en el backend
          final user = User(
            nombres: nombresController.text,
            apellidos: apellidosController.text,
            cedula: cedulaController.text,
            direccion: direccionController.text,
            celular: celularController.text,
            email: emailController.text,
            seguro: seguroController.text,
            password: '', // Contraseña temporal, se actualizará en generar contraseña
          );
          
          // Guardar en Hive local
          await UserService.saveUser(user);
          
          if (mounted) {
            // Ir a crear contraseña con los datos previos
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GenerarContrasenaScreen(user: user, prepagaCode: prepagaCode),
              ),
            );
          }
        }
      } catch (e) {
        // Cerrar el indicador de carga en caso de error
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error de Conexión'),
                content: Text('No se pudo conectar con el servidor: $e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              );
            },
          );
        }
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo a color
                  Image.asset(
                    'assets/icons/logo_color.png',
                    width: 180,
                  ),
                  const SizedBox(height: 18),
                  // Título
                  const Text(
                    'Crear registro de usuario',
                    style: TextStyle(
                      color: Color(0xFF19E2D7),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Campos de texto
                  _CustomTextField(label: 'Nombres', controller: nombresController),
                  const SizedBox(height: 16),
                  _CustomTextField(label: 'Apellidos', controller: apellidosController),
                  const SizedBox(height: 16),
                  _CustomNumericTextField(label: 'Cédula de Identidad', controller: cedulaController),
                  const SizedBox(height: 16),
                  _CustomTextField(label: 'Dirección particular', controller: direccionController),
                  const SizedBox(height: 16),
                  _CustomNumericTextField(label: 'Número de celular', controller: celularController),
                  const SizedBox(height: 16),
                  _CustomTextField(label: 'Email', controller: emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedPrepagaCode,
                    decoration: const InputDecoration(
                      labelText: 'Seguro médico / alianzas',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF09D5D6)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF09D5D6), width: 2),
                      ),
                    ),
                    items: prepagasOptions
                        .map((opt) => DropdownMenuItem<int>(
                              value: opt['code'] as int,
                              child: Text(
                                opt['label'] as String,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedPrepagaCode = val;
                        final label = prepagasOptions.firstWhere((o) => o['code'] == val)['label'] as String;
                        seguroController.text = label;
                      });
                    },
                    validator: (val) {
                      if (val == null) {
                        return 'Seleccione una opción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Botón de registro
                  Center(
                    child: SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: _registrarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[200],
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
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  const _CustomTextField({required this.label, this.controller, this.obscureText = false, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF09D5D6)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF09D5D6), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obligatorio';
        }
        return null;
      },
    );
  }
}

class _CustomNumericTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  const _CustomNumericTextField({required this.label, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF09D5D6)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF09D5D6), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obligatorio';
        }
        // Validación específica según el tipo de campo
        if (label.toLowerCase().contains('cédula')) {
          if (value.length < 7) {
            return 'La cédula debe tener al menos 7 dígitos';
          }
        } else if (label.toLowerCase().contains('celular')) {
          if (value.length < 10) {
            return 'El número de celular debe tener al menos 10 dígitos';
          }
        }
        return null;
      },
    );
  }
} 