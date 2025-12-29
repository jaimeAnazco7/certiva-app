import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'client_api_service.dart';

class UserService {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'currentUser';
  static const String _loginCredentialsKey = 'loginCredentials';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(UserAdapter());
      await Hive.openBox<User>(_boxName);
      await Hive.openBox(_currentUserKey);
      await Hive.openBox(_loginCredentialsKey);
    } catch (e) {
      print('Error inicializando Hive en UserService: $e');
      // Reintentar después de un delay más largo
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        await Hive.initFlutter();
        Hive.registerAdapter(UserAdapter());
        await Hive.openBox<User>(_boxName);
        await Hive.openBox(_currentUserKey);
        await Hive.openBox(_loginCredentialsKey);
      } catch (e2) {
        print('Error en segundo intento de inicialización de Hive: $e2');
        // Lanzar el error para que la app sepa que Hive no está disponible
        rethrow;
      }
    }
  }

  // Guardar usuario
  static Future<void> saveUser(User user) async {
    final box = Hive.box<User>(_boxName);
    await box.put(user.email, user);
  }

  // Obtener usuario por email - SOLO HIVE (para login rápido)
  static Future<User?> getUserByEmail(String email) async {
    print('🔍 [UserService] Buscando usuario por email: $email');
    
    // Para el login, solo usar Hive para que sea rápido
    final box = Hive.box<User>(_boxName);
    final hiveUser = box.get(email);
    
    if (hiveUser != null) {
      print('💾 [UserService] Usuario encontrado en Hive');
      print('📊 [UserService] Datos de Hive: ${hiveUser.toMap()}');
    } else {
      print('❌ [UserService] Usuario no encontrado en Hive');
    }
    
    return hiveUser;
  }

  // Obtener usuario por email con sincronización API (para pantallas que necesiten datos actualizados)
  static Future<User?> getUserByEmailWithApiSync(String email) async {
    print('🔍 [UserService] Buscando usuario por email con sincronización API: $email');
    
    // Primero intentar obtener desde la API si tenemos un idCliente
    final currentUser = getCurrentUser();
    if (currentUser?.idCliente != null) {
      print('🌐 [UserService] Intentando obtener desde API con idCliente: ${currentUser!.idCliente}');
      try {
        final apiUser = await ClientApiService.getClientById(currentUser.idCliente!);
        if (apiUser != null) {
          print('✅ [UserService] Usuario obtenido desde API exitosamente');
          print('📊 [UserService] Datos de API: ${apiUser.toMap()}');
          
          // Actualizar en Hive con los datos más recientes de la API
          await saveUser(apiUser);
          print('💾 [UserService] Datos de API guardados en Hive');
          
          return apiUser;
        } else {
          print('❌ [UserService] API no devolvió datos para idCliente: ${currentUser.idCliente}');
        }
      } catch (e) {
        print('🚨 [UserService] Error al obtener usuario desde la API: $e');
      }
    } else {
      print('⚠️ [UserService] No hay idCliente disponible, intentando buscar por email en API...');
      
      // Intentar buscar por email en la API
      try {
        final apiUser = await ClientApiService.getClientByEmail(email);
        if (apiUser != null) {
          print('✅ [UserService] Usuario encontrado en API por email');
          print('📊 [UserService] Datos de API: ${apiUser.toMap()}');
          
          // Actualizar en Hive con los datos de la API
          await saveUser(apiUser);
          print('💾 [UserService] Datos de API guardados en Hive');
          
          return apiUser;
        } else {
          print('❌ [UserService] Usuario no encontrado en API por email');
        }
      } catch (e) {
        print('🚨 [UserService] Error al buscar usuario por email en API: $e');
      }
    }

    // Si no se pudo obtener desde la API, usar Hive como respaldo
    print('📱 [UserService] Usando Hive como respaldo...');
    final box = Hive.box<User>(_boxName);
    final hiveUser = box.get(email);
    
    if (hiveUser != null) {
      print('💾 [UserService] Usuario encontrado en Hive');
      print('📊 [UserService] Datos de Hive: ${hiveUser.toMap()}');
    } else {
      print('❌ [UserService] Usuario no encontrado ni en API ni en Hive');
    }
    
    return hiveUser;
  }

  // Obtener usuario por email (versión síncrona para compatibilidad)
  static User? getUserByEmailSync(String email) {
    final box = Hive.box<User>(_boxName);
    return box.get(email);
  }

  // Verificar login
  static bool login(String email, String password) {
    final user = getUserByEmailSync(email);
    if (user != null && user.password == password) {
      _setCurrentUser(user);
      return true;
    }
    return false;
  }

  // Obtener usuario actual
  static User? getCurrentUser() {
    final box = Hive.box(_currentUserKey);
    final userData = box.get('user');
    if (userData != null) {
      return User.fromMap(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  // Establecer usuario actual
  static void _setCurrentUser(User user) {
    final box = Hive.box(_currentUserKey);
    box.put('user', user.toMap());
  }

  // Método público para establecer el usuario actual
  static void setCurrentUser(User user) {
    _setCurrentUser(user);
  }

  // Cerrar sesión
  static void logout() {
    final box = Hive.box(_currentUserKey);
    box.delete('user');
  }

  // Limpiar usuario actual (alias para logout)
  static void clearCurrentUser() {
    logout();
  }

  // Verificar si hay usuario logueado
  static bool isLoggedIn() {
    return getCurrentUser() != null;
  }

  // Obtener todos los usuarios (para debug)
  static List<User> getAllUsers() {
    final box = Hive.box<User>(_boxName);
    return box.values.toList();
  }

  // Sincronizar usuario con la API
  static Future<User?> syncUserWithApi(int idCliente) async {
    try {
      final apiUser = await ClientApiService.getClientById(idCliente);
      if (apiUser != null) {
        // Guardar en Hive para uso offline
        await saveUser(apiUser);
        return apiUser;
      }
    } catch (e) {
      print('Error al sincronizar usuario con la API: $e');
    }
    return null;
  }

  // Sincronizar usuario por email en segundo plano (sin bloquear la UI)
  static Future<void> syncUserByEmailInBackground(String email) async {
    print('🔄 [UserService] Iniciando sincronización en segundo plano para: $email');
    
    try {
      // Buscar por email en la API sin bloquear
      final apiUser = await ClientApiService.getClientByEmail(email);
      if (apiUser != null) {
        print('✅ [UserService] Sincronización exitosa en segundo plano');
        print('📊 [UserService] Datos actualizados: ${apiUser.toMap()}');
        
        // Actualizar en Hive
        await saveUser(apiUser);
        
        // Si es el usuario actual, actualizar también
        final currentUser = getCurrentUser();
        if (currentUser?.email == email) {
          setCurrentUser(apiUser);
          print('🔄 [UserService] Usuario actual actualizado con datos de API');
        }
      } else {
        print('❌ [UserService] No se pudo sincronizar en segundo plano');
      }
    } catch (e) {
      print('🚨 [UserService] Error en sincronización en segundo plano: $e');
    }
  }

  // Buscar usuario por cédula - PRIORIDAD: API primero, luego Hive
  static Future<User?> getUserByCedula(String cedula) async {
    // Primero intentar obtener desde la API si tenemos un idCliente
    final currentUser = getCurrentUser();
    if (currentUser?.idCliente != null) {
      try {
        final apiUser = await ClientApiService.getClientById(currentUser!.idCliente!);
        if (apiUser != null && apiUser.cedula == cedula) {
          // Actualizar en Hive con los datos más recientes de la API
          await saveUser(apiUser);
          return apiUser;
        }
      } catch (e) {
        print('Error al obtener usuario desde la API: $e');
      }
    }

    // Si no se pudo obtener desde la API, usar Hive como respaldo
    final box = Hive.box<User>(_boxName);
    try {
      return box.values.firstWhere(
        (user) => user.cedula == cedula,
      );
    } catch (e) {
      // Si no se encuentra el usuario, retornar null
      return null;
    }
  }

  // ========== MÉTODOS PARA "RECORDAR MIS DATOS" ==========

  // Guardar credenciales de login (email y password)
  static Future<void> saveLoginCredentials(String email, String password) async {
    final box = Hive.box(_loginCredentialsKey);
    await box.put('email', email);
    await box.put('password', password);
    await box.put('rememberMe', true);
    print('💾 [UserService] Credenciales guardadas para: $email');
  }

  // Cargar credenciales de login guardadas
  static Map<String, String?>? getSavedLoginCredentials() {
    final box = Hive.box(_loginCredentialsKey);
    final email = box.get('email') as String?;
    final password = box.get('password') as String?;
    final rememberMe = box.get('rememberMe') as bool? ?? false;

    if (email != null && password != null && rememberMe) {
      print('📋 [UserService] Credenciales encontradas para: $email');
      return {
        'email': email,
        'password': password,
      };
    }
    print('❌ [UserService] No hay credenciales guardadas');
    return null;
  }

  // Eliminar credenciales guardadas
  static Future<void> clearLoginCredentials() async {
    final box = Hive.box(_loginCredentialsKey);
    await box.delete('email');
    await box.delete('password');
    await box.delete('rememberMe');
    print('🗑️ [UserService] Credenciales eliminadas');
  }

  // Verificar si hay credenciales guardadas
  static bool hasSavedCredentials() {
    final box = Hive.box(_loginCredentialsKey);
    final email = box.get('email') as String?;
    final rememberMe = box.get('rememberMe') as bool? ?? false;
    return email != null && rememberMe;
  }
} 