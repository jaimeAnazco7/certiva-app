import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/client_api_service.dart';

class MisDatosScreen extends StatefulWidget {
  const MisDatosScreen({Key? key}) : super(key: key);

  @override
  State<MisDatosScreen> createState() => _MisDatosScreenState();
}

class _MisDatosScreenState extends State<MisDatosScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombresController;
  late TextEditingController apellidosController;
  late TextEditingController cedulaController;
  late TextEditingController direccionController;
  late TextEditingController celularController;
  late TextEditingController emailController;
  late TextEditingController seguroController;
  late TextEditingController rucController;
  late TextEditingController razonSocialController;
  String? selectedSexo; // "1" = MASCULINO, "2" = FEMENINO
  bool isEditing = false;
  bool isSaving = false; // Para mostrar loading al guardar

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Sincronizar con API en segundo plano cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserDataInBackground();
    });
  }

  // Sincronizar datos del usuario en segundo plano
  void _syncUserDataInBackground() {
    final currentUser = UserService.getCurrentUser();
    if (currentUser != null) {
      print('🔄 [MisDatosScreen] Iniciando sincronización automática en segundo plano...');
      UserService.syncUserByEmailInBackground(currentUser.email).then((_) {
        // Refrescar la pantalla si los datos cambiaron
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _loadUserData() {
    final currentUser = UserService.getCurrentUser();
    if (currentUser != null) {
      nombresController = TextEditingController(text: currentUser.nombres);
      apellidosController = TextEditingController(text: currentUser.apellidos);
      cedulaController = TextEditingController(text: currentUser.cedula);
      direccionController = TextEditingController(text: currentUser.direccion);
      celularController = TextEditingController(text: currentUser.celular);
      emailController = TextEditingController(text: currentUser.email);
      seguroController = TextEditingController(text: currentUser.seguro);
      rucController = TextEditingController(text: currentUser.ruc ?? '');
      razonSocialController = TextEditingController(text: currentUser.razonSocial ?? '');
      selectedSexo = currentUser.sexo; // "1" o "2"
    } else {
      // Si no hay usuario, inicializar con valores vacíos
      nombresController = TextEditingController();
      apellidosController = TextEditingController();
      cedulaController = TextEditingController();
      direccionController = TextEditingController();
      celularController = TextEditingController();
      emailController = TextEditingController();
      seguroController = TextEditingController();
      rucController = TextEditingController();
      razonSocialController = TextEditingController();
      selectedSexo = null;
    }
  }

  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    cedulaController.dispose();
    direccionController.dispose();
    celularController.dispose();
    emailController.dispose();
    seguroController.dispose();
    rucController.dispose();
    razonSocialController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = UserService.getCurrentUser();
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No hay usuario logueado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verificar que tenga idCliente para poder actualizar en la API
      if (currentUser.idCliente == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se puede actualizar sin ID de cliente'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // IMPORTANTE: La API usa el email para identificar al usuario, no para actualizarlo
      // Por lo tanto, siempre debemos usar el email original del usuario registrado
      // No el email del controlador (que puede estar vacío o modificado)
      String email = currentUser.email.trim();
      
      // Validaciones nuevas según API: teléfono, dirección, idPrepaga
      if (celularController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: El teléfono es obligatorio'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (direccionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: La dirección es obligatoria'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (seguroController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: La prepaga (idPrepaga) es obligatoria'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('📧 [MisDatosScreen] Usando email original del usuario: $email');
      print('📧 [MisDatosScreen] Email en controlador: ${emailController.text}');

      setState(() {
        isSaving = true;
      });

      try {
        print('📧 [MisDatosScreen] Email a enviar: $email');
        print('📧 [MisDatosScreen] Email del controlador: ${emailController.text}');
        print('📧 [MisDatosScreen] Email del usuario actual: ${currentUser.email}');
        print('📧 [MisDatosScreen] ID Cliente: ${currentUser.idCliente}');
        
        // Llamar a la API para actualizar los datos con la nueva especificación
        final result = await ClientApiService.updateClientData(
          idCliente: currentUser.idCliente!,
          idPrepaga: seguroController.text.trim(), // obligatorio
          telefono: celularController.text.trim(),
          direccion: direccionController.text.trim(),
        );

        if (result != null && result['success'] == true) {
          // Si la API actualizó correctamente, actualizar el usuario local
          final updatedUser = User(
            nombres: nombresController.text,
            apellidos: apellidosController.text,
            cedula: cedulaController.text,
            direccion: direccionController.text,
            celular: celularController.text,
            email: emailController.text,
            seguro: seguroController.text,
            password: currentUser.password, // Mantener la contraseña actual
            idCliente: currentUser.idCliente, // IMPORTANTE: Preservar el ID de cliente
            ruc: rucController.text.trim().isNotEmpty ? rucController.text.trim() : null,
            razonSocial: razonSocialController.text.trim().isNotEmpty ? razonSocialController.text.trim() : null,
            sexo: selectedSexo,
          );

          await UserService.saveUser(updatedUser);
          // Actualizar el usuario actual con los nuevos datos
          UserService.setCurrentUser(updatedUser);
          
          // Recargar los datos en los controladores
          _loadUserData();
          
          if (mounted) {
            setState(() {
              isEditing = false;
              isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Datos guardados correctamente'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          // Error al actualizar en la API
          if (mounted) {
            setState(() {
              isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result?['message'] ?? 'Error al actualizar datos en el servidor'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        print('🚨 [MisDatosScreen] Error al guardar: $e');
        if (mounted) {
          setState(() {
            isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de conexión: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.getCurrentUser();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFB47EDB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis datos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Indicador de fuente de datos
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: currentUser?.idCliente != null ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  currentUser?.idCliente != null ? Icons.cloud_done : Icons.phone_android,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  currentUser?.idCliente != null ? 'API' : 'HIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: _toggleEditing,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar mis datos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Información de fuente de datos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: currentUser?.idCliente != null ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentUser?.idCliente != null ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      currentUser?.idCliente != null ? Icons.cloud_done : Icons.phone_android,
                      color: currentUser?.idCliente != null ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.idCliente != null ? 'Datos sincronizados desde API' : 'Datos locales de Hive',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: currentUser?.idCliente != null ? Colors.green : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser?.idCliente != null 
                              ? 'ID Cliente: ${currentUser!.idCliente} • Última actualización: Ahora'
                              : 'Sin conexión a API • Última actualización: Al registrarse',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Campos de datos
              _buildDataField(
                label: 'Nombres',
                controller: nombresController,
                enabled: isEditing,
              ),
              const SizedBox(height: 16),
              _buildDataField(
                label: 'Apellidos',
                controller: apellidosController,
                enabled: isEditing,
              ),
              const SizedBox(height: 16),
              _buildDataField(
                label: 'Cédula de Identidad',
                controller: cedulaController,
                enabled: false, // La cédula NUNCA se puede editar
                isReadOnly: true, // Marcado como solo lectura
              ),
              const SizedBox(height: 16),
              _buildDataField(
                label: 'Dirección particular',
                controller: direccionController,
                enabled: isEditing,
              ),
              const SizedBox(height: 16),
              _buildDataField(
                label: 'Número de celular',
                controller: celularController,
                enabled: isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildDataField(
                label: 'Email',
                controller: emailController,
                enabled: isEditing,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildDataField(
                label: 'Seguro médico/alianzas',
                controller: seguroController,
                enabled: isEditing,
              ),
              const SizedBox(height: 16),
              _buildDataField(
                label: 'RUC',
                controller: rucController,
                enabled: isEditing,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              _buildDataField(
                label: 'Razón Social',
                controller: razonSocialController,
                enabled: isEditing,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              _buildSexoDropdown(),
              const SizedBox(height: 32),
              // Botón de debug para ver logs
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final currentUser = UserService.getCurrentUser();
                    if (currentUser != null) {
                      print('🔍 [DEBUG] Usuario actual:');
                      print('🔍 [DEBUG] ${currentUser.toMap()}');
                      print('🔍 [DEBUG] ID Cliente: ${currentUser.idCliente}');
                      print('🔍 [DEBUG] Fuente: ${currentUser.idCliente != null ? "API" : "HIVE"}');
                      
                      // Intentar sincronizar en segundo plano
                      print('🔄 [DEBUG] Iniciando sincronización en segundo plano...');
                      await UserService.syncUserByEmailInBackground(currentUser.email);
                      
                      // Refrescar la pantalla
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.bug_report),
                                        label: const Text('Debug - Sincronizar con API'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botón guardar
              if (isEditing)
                Center(
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB47EDB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Guardar cambios',
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
              // Logo de Certiva
              Center(
                child: Image.asset(
                  'assets/icons/logo_color.png',
                  width: 151,
                  height: 76,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    bool isReadOnly = false, // Nuevo parámetro para campos de solo lectura
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                keyboardType: keyboardType,
                style: TextStyle(
                  color: isReadOnly ? Colors.grey : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: isReadOnly ? Colors.grey : Color(0xFF09D5D6)),
                  ),
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: isReadOnly ? Colors.grey : Color(0xFF09D5D6)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: isReadOnly ? Colors.grey : Color(0xFF09D5D6)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF09D5D6), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                validator: enabled && !isReadOnly ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  return null;
                } : null,
              ),
            ),
            if (!enabled && !isReadOnly)
              const Icon(
                Icons.edit,
                color: Color(0xFF09D5D6),
                size: 20,
              ),
            if (isReadOnly)
              const Icon(
                Icons.lock,
                color: Colors.grey,
                size: 20,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSexoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sexo',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedSexo,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF09D5D6)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF09D5D6)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF09D5D6), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Seleccionar...', style: TextStyle(color: Colors.grey)),
                  ),
                  const DropdownMenuItem<String>(
                    value: '1',
                    child: Text('MASCULINO'),
                  ),
                  const DropdownMenuItem<String>(
                    value: '2',
                    child: Text('FEMENINO'),
                  ),
                ],
                onChanged: isEditing
                    ? (String? value) {
                        setState(() {
                          selectedSexo = value;
                        });
                      }
                    : null,
                style: TextStyle(
                  color: isEditing ? Colors.black87 : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            if (!isEditing)
              const Icon(
                Icons.edit,
                color: Color(0xFF09D5D6),
                size: 20,
              ),
          ],
        ),
      ],
    );
  }
}