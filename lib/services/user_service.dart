import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/user.dart';
import 'client_api_service.dart';

class UserService {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'currentUser';
  static const String _loginCredentialsKey = 'loginCredentials';

  static Future<void> init() async {
    final startTime = DateTime.now();
    final initLog = '📦 [UserService] Iniciando inicialización de Hive - ${startTime.toIso8601String()}';
    // FirebaseCrashlytics.instance.log(initLog);
    debugPrint(initLog);
    
    try {
      // Usar Library Directory en iOS para mejor compatibilidad con iOS 18
      String? path;
      if (Platform.isIOS) {
        final libraryDir = await getLibraryDirectory();
        path = libraryDir.path;
        debugPrint('🍎 [UserService] Usando Library Directory para iOS: $path');
      }

      debugPrint('📦 [UserService] Paso 1/5: Inicializando Hive...');

      // === AGREGA ESTA LÍNEA JUSTO AQUÍ ===
      final beforeInitFlutter = DateTime.now();


      if (path != null) {
        await Hive.initFlutter(path);
      } else {
        await Hive.initFlutter();
      }
      final afterInitFlutter = DateTime.now();
      final initFlutterDuration = afterInitFlutter.difference(beforeInitFlutter);
      final successLog = '✅ [UserService] Hive.initFlutter() completado en ${initFlutterDuration.inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(successLog);
      debugPrint(successLog);
      
      // FirebaseCrashlytics.instance.log('📦 [UserService] Paso 2/5: Registrando UserAdapter...');
      debugPrint('📦 [UserService] Paso 2/5: Registrando UserAdapter...');
      final beforeAdapter = DateTime.now();
      Hive.registerAdapter(UserAdapter());
      final afterAdapter = DateTime.now();
      final adapterDuration = afterAdapter.difference(beforeAdapter);
      final adapterLog = '✅ [UserService] UserAdapter registrado en ${adapterDuration.inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(adapterLog);
      debugPrint(adapterLog);
      
      // FirebaseCrashlytics.instance.log('📦 [UserService] Paso 3/5: Abriendo box de usuarios...');
      debugPrint('📦 [UserService] Paso 3/5: Abriendo box de usuarios...');
      final beforeUsersBox = DateTime.now();
      await Hive.openBox<User>(_boxName);
      final afterUsersBox = DateTime.now();
      final usersBoxDuration = afterUsersBox.difference(beforeUsersBox);
      final usersBoxLog = '✅ [UserService] Box de usuarios abierto en ${usersBoxDuration.inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(usersBoxLog);
      debugPrint(usersBoxLog);
      
      // FirebaseCrashlytics.instance.log('📦 [UserService] Paso 4/5: Abriendo box de usuario actual...');
      debugPrint('📦 [UserService] Paso 4/5: Abriendo box de usuario actual...');
      final beforeCurrentUserBox = DateTime.now();
      await Hive.openBox(_currentUserKey);
      final afterCurrentUserBox = DateTime.now();
      final currentUserBoxDuration = afterCurrentUserBox.difference(beforeCurrentUserBox);
      final currentUserBoxLog = '✅ [UserService] Box de usuario actual abierto en ${currentUserBoxDuration.inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(currentUserBoxLog);
      debugPrint(currentUserBoxLog);
      
      // FirebaseCrashlytics.instance.log('📦 [UserService] Paso 5/5: Abriendo box de credenciales...');
      debugPrint('📦 [UserService] Paso 5/5: Abriendo box de credenciales...');
      final beforeCredentialsBox = DateTime.now();
      await Hive.openBox(_loginCredentialsKey);
      final afterCredentialsBox = DateTime.now();
      final credentialsBoxDuration = afterCredentialsBox.difference(beforeCredentialsBox);
      final credentialsBoxLog = '✅ [UserService] Box de credenciales abierto en ${credentialsBoxDuration.inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(credentialsBoxLog);
      debugPrint(credentialsBoxLog);
      
      final endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime);
      final totalLog = '✅ [UserService] Inicialización de Hive completada exitosamente en ${totalDuration.inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(totalLog);
      debugPrint(totalLog);
    } catch (e, stackTrace) {
      final errorTime = DateTime.now();
      final errorDuration = errorTime.difference(startTime);
      final errorLog = '❌ [UserService] Error inicializando Hive después de ${errorDuration.inMilliseconds}ms';
      // FirebaseCrashlytics.instance.log(errorLog);
      debugPrint(errorLog);
      // FirebaseCrashlytics.instance.log('❌ [UserService] Error: $e');
      debugPrint('❌ [UserService] Error: $e');
      // FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: false);
      debugPrint('❌ [UserService] Stack trace: $stackTrace');
      
      // Reintentar después de un delay más largo
      // FirebaseCrashlytics.instance.log('⏳ [UserService] Esperando 500ms antes del segundo intento...');
      debugPrint('⏳ [UserService] Esperando 500ms antes del segundo intento...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // FirebaseCrashlytics.instance.log('🔄 [UserService] Segundo intento de inicialización...');
      debugPrint('🔄 [UserService] Segundo intento de inicialización...');
      try {
        final secondStartTime = DateTime.now();
        // FirebaseCrashlytics.instance.log('📦 [UserService] Segundo intento - Llamando Hive.initFlutter()...');
        debugPrint('📦 [UserService] Segundo intento - Llamando Hive.initFlutter()...');
        await Hive.initFlutter();
        // FirebaseCrashlytics.instance.log('✅ [UserService] Segundo intento - Hive.initFlutter() completado');
        debugPrint('✅ [UserService] Segundo intento - Hive.initFlutter() completado');
        
        // FirebaseCrashlytics.instance.log('📦 [UserService] Segundo intento - Registrando UserAdapter...');
        debugPrint('📦 [UserService] Segundo intento - Registrando UserAdapter...');
        Hive.registerAdapter(UserAdapter());
        // FirebaseCrashlytics.instance.log('✅ [UserService] Segundo intento - UserAdapter registrado');
        debugPrint('✅ [UserService] Segundo intento - UserAdapter registrado');
        
        // FirebaseCrashlytics.instance.log('📦 [UserService] Segundo intento - Abriendo boxes...');
        debugPrint('📦 [UserService] Segundo intento - Abriendo boxes...');
        await Hive.openBox<User>(_boxName);
        await Hive.openBox(_currentUserKey);
        await Hive.openBox(_loginCredentialsKey);
        
        final secondEndTime = DateTime.now();
        final secondDuration = secondEndTime.difference(secondStartTime);
        final secondSuccessLog = '✅ [UserService] Segundo intento exitoso en ${secondDuration.inMilliseconds}ms';
        // FirebaseCrashlytics.instance.log(secondSuccessLog);
        debugPrint(secondSuccessLog);
      } catch (e2, stackTrace2) {
        final finalErrorTime = DateTime.now();
        final finalDuration = finalErrorTime.difference(startTime);
        final finalErrorLog = '❌ [UserService] Error en segundo intento después de ${finalDuration.inMilliseconds}ms total';
        // FirebaseCrashlytics.instance.log(finalErrorLog);
        debugPrint(finalErrorLog);
        // FirebaseCrashlytics.instance.log('❌ [UserService] Error: $e2');
        debugPrint('❌ [UserService] Error: $e2');
        // FirebaseCrashlytics.instance.recordError(e2, stackTrace2, fatal: false);
        debugPrint('❌ [UserService] Stack trace: $stackTrace2');
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