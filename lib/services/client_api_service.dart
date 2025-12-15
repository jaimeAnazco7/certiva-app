import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart' as app_user;
import 'user_service.dart';

class ClientApiService {
  static const String _baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
  static const String _username = 'CERTIVA_APP';
  static const String _password = 'CerTiva2028*';

  // Obtener credenciales de autenticación
  static String _getBasicAuth() {
    final String rawAuth = '${Uri.encodeComponent(_username)}:${Uri.encodeComponent(_password)}';
    return 'Basic ' + base64Encode(utf8.encode(rawAuth));
  }

  // Obtener cliente por ID desde la API
  static Future<app_user.User?> getClientById(int idCliente) async {
    print('🌐 [ClientApiService] Consultando API para idCliente: $idCliente');
    print('🌐 [ClientApiService] URL: $_baseUrl/app/get_cliente/$idCliente');
    
    try {
      final url = Uri.parse('$_baseUrl/app/get_cliente/$idCliente');
      final response = await http.get(
        url,
        headers: {
          'Authorization': _getBasicAuth(),
          'Content-Type': 'application/json',
        },
      );

      print('🌐 [ClientApiService] Status Code: ${response.statusCode}');
      print('🌐 [ClientApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Intentar diferentes formatos de respuesta
        Map<String, dynamic>? clienteData;
        
        // Formato 1: { "clientes": [...] }
        if (responseData['clientes'] != null && 
            responseData['clientes'] is List && 
            responseData['clientes'].isNotEmpty) {
          clienteData = responseData['clientes'][0];
        }
        // Formato 2: Datos directos en la raíz
        else if (responseData['id_cliente'] != null || responseData['nombre'] != null) {
          clienteData = responseData;
        }
        // Formato 3: { "cliente": {...} }
        else if (responseData['cliente'] != null) {
          clienteData = responseData['cliente'];
        }
        
        if (clienteData != null) {
          // Convertir los datos de la API al modelo User de la app
          final mappedUser = app_user.User(
            nombres: clienteData['nombre'] ?? '',
            apellidos: clienteData['apellido'] ?? '',
            cedula: clienteData['cedula']?.toString() ?? '',
            direccion: clienteData['direccion'] ?? '',
            celular: clienteData['telefono'] ?? '',
            email: clienteData['email'] ?? '',
            seguro: clienteData['prepaga']?.toString() ?? '',
            password: '', // La API no devuelve contraseña por seguridad
            idCliente: clienteData['id_cliente'] ?? idCliente,
            ruc: clienteData['ruc']?.toString(),
            razonSocial: clienteData['razon_social']?.toString(),
            sexo: clienteData['sex_id_sexo']?.toString(),
          );
          
          print('🔄 [ClientApiService] Datos mapeados exitosamente:');
          print('🔄 [ClientApiService] Nombre: ${clienteData['nombre']} → ${mappedUser.nombres}');
          print('🔄 [ClientApiService] Apellido: ${clienteData['apellido']} → ${mappedUser.apellidos}');
          print('🔄 [ClientApiService] Cédula: ${clienteData['cedula']} → ${mappedUser.cedula}');
          print('🔄 [ClientApiService] ID Cliente: ${clienteData['id_cliente']} → ${mappedUser.idCliente}');
          
          return mappedUser;
        } else {
          print('⚠️ [ClientApiService] Respuesta 200 pero formato no reconocido');
          print('⚠️ [ClientApiService] Response data: $responseData');
        }
      } else if (response.statusCode == 404) {
          print('❌ [ClientApiService] Cliente no encontrado en la API (404)');
          return null;
        } else {
          print('🚨 [ClientApiService] Error en la API: ${response.statusCode}');
          return null;
        }
    } catch (e) {
      print('Error al consultar la API de clientes: $e');
      return null;
    }
    
    return null;
  }

  // Obtener ID de cliente por email usando la API de autenticación
  static Future<int?> getClientIdByEmail(String email) async {
    print('🌐 [ClientApiService] Obteniendo ID de cliente por email: $email');
    print('🌐 [ClientApiService] URL: $_baseUrl/app/post_autenticacion');
    
    try {
      final url = Uri.parse('$_baseUrl/app/post_autenticacion');
      final response = await http.post(
        url,
        headers: {
          'Authorization': _getBasicAuth(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      print('🌐 [ClientApiService] Status Code: ${response.statusCode}');
      print('🌐 [ClientApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success' && responseData['id_cliente'] != null) {
          final idCliente = responseData['id_cliente'];
          print('✅ [ClientApiService] ID Cliente obtenido: $idCliente');
          return idCliente;
        } else {
          print('❌ [ClientApiService] Respuesta no contiene id_cliente válido');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('❌ [ClientApiService] Correo no registrado en la API (404)');
        return null;
      } else {
        print('🚨 [ClientApiService] Error en la API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🚨 [ClientApiService] Error al consultar API de autenticación: $e');
      return null;
    }
  }

  // Obtener cliente completo por email (primero obtiene ID, luego datos completos)
  static Future<app_user.User?> getClientByEmail(String email) async {
    print('🌐 [ClientApiService] Buscando cliente por email: $email');
    
    try {
      // Paso 1: Obtener el ID del cliente usando la API de autenticación
      final idCliente = await getClientIdByEmail(email);
      
      if (idCliente == null) {
        print('❌ [ClientApiService] No se pudo obtener ID de cliente para email: $email');
        return null;
      }
      
      // Paso 2: Obtener los datos completos del cliente usando el ID
      print('🔄 [ClientApiService] Obteniendo datos completos para ID: $idCliente');
      final user = await getClientById(idCliente);
      
      if (user != null) {
        print('✅ [ClientApiService] Usuario completo obtenido exitosamente');
        return user;
      } else {
        // Si el endpoint devuelve 404, puede ser un problema del endpoint
        // Intentar obtener datos desde Hive como respaldo
        print('⚠️ [ClientApiService] Endpoint get_cliente devolvió 404 para ID: $idCliente');
        print('⚠️ [ClientApiService] Esto puede ser un problema del endpoint');
        print('⚠️ [ClientApiService] Intentando obtener datos desde Hive...');
        
        // Intentar obtener desde Hive si existe
        try {
          final hiveUser = await UserService.getUserByEmail(email);
          if (hiveUser != null) {
            print('✅ [ClientApiService] Usuario encontrado en Hive');
            // Actualizar el idCliente si no estaba o si es diferente
            if (hiveUser.idCliente == null || hiveUser.idCliente != idCliente) {
              print('🔄 [ClientApiService] Actualizando idCliente en usuario de Hive');
              final updatedUser = app_user.User(
                nombres: hiveUser.nombres,
                apellidos: hiveUser.apellidos,
                cedula: hiveUser.cedula,
                direccion: hiveUser.direccion,
                celular: hiveUser.celular,
                email: hiveUser.email,
                seguro: hiveUser.seguro,
                password: hiveUser.password,
                idCliente: idCliente,
                ruc: hiveUser.ruc,
                razonSocial: hiveUser.razonSocial,
                sexo: hiveUser.sexo,
              );
              return updatedUser;
            }
            return hiveUser;
          } else {
            print('❌ [ClientApiService] No se encontró usuario en Hive');
          }
        } catch (e) {
          print('⚠️ [ClientApiService] Error al buscar en Hive: $e');
        }
        
        // Si no hay datos en Hive ni en la API, retornar null
        // El usuario deberá usar login normal o el backend debe arreglar el endpoint
        print('❌ [ClientApiService] No se pudieron obtener datos del cliente');
        print('❌ [ClientApiService] El endpoint /app/get_cliente/$idCliente devuelve 404');
        print('❌ [ClientApiService] Y no hay datos guardados en Hive');
        return null;
      }
    } catch (e) {
      print('🚨 [ClientApiService] Error al buscar cliente por email: $e');
      return null;
    }
  }

  // Obtener cliente por cédula desde la API
  static Future<app_user.User?> getClientByCedula(String cedula) async {
    try {
      // Como la API no tiene endpoint por cédula, necesitamos implementar una búsqueda
      // Por ahora, retornamos null y se usará Hive como respaldo
      // TODO: Implementar búsqueda por cédula si la API lo permite
      print('Búsqueda por cédula no implementada en la API actual');
      return null;
    } catch (e) {
      print('Error al buscar cliente por cédula en la API: $e');
      return null;
    }
  }

  // Solicitar recuperación de contraseña (envía email al usuario)
  static Future<bool> requestPasswordReset(String email) async {
    print('📧 [ClientApiService] Solicitando recuperación de contraseña para: $email');
    print('📧 [ClientApiService] URL: $_baseUrl/app/user/password_reset');
    
    try {
      final url = Uri.parse('$_baseUrl/app/user/password_reset');
      final response = await http.post(
        url,
        headers: {
          'Authorization': _getBasicAuth(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      print('📧 [ClientApiService] Status Code: ${response.statusCode}');
      print('📧 [ClientApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Verificar si la respuesta indica éxito
        // La API puede devolver diferentes formatos, ajustar según la respuesta real
        if (responseData['status'] == 'success' || 
            responseData['message'] != null ||
            response.statusCode == 200) {
          print('✅ [ClientApiService] Email de recuperación enviado exitosamente');
          return true;
        } else {
          print('⚠️ [ClientApiService] Respuesta inesperada de la API');
          return false;
        }
      } else if (response.statusCode == 404) {
        print('❌ [ClientApiService] Email no encontrado en la base de datos (404)');
        return false;
      } else {
        print('🚨 [ClientApiService] Error en la API: ${response.statusCode}');
        print('🚨 [ClientApiService] Mensaje: ${response.body}');
        return false;
      }
    } catch (e) {
      print('🚨 [ClientApiService] Error al solicitar recuperación de contraseña: $e');
      return false;
    }
  }

  // Actualizar datos del cliente
  static Future<Map<String, dynamic>?> updateClientData({
    required int idCliente,
    required String idPrepaga, // Nuevo: obligatorio según documentación
    String? telefono,
    String? direccion,
  }) async {
    print('🔄 [ClientApiService] Actualizando datos del cliente ID: $idCliente');
    print('🔄 [ClientApiService] URL: $_baseUrl/app/put_modificar_usuario');
    
    try {
      // Validaciones mínimas
      if (idPrepaga.isEmpty) {
        print('❌ [ClientApiService] idPrepaga vacío, no se puede actualizar');
        return {
          'success': false,
          'message': 'El idPrepaga es obligatorio',
        };
      }

      if (telefono == null || telefono.isEmpty) {
        print('❌ [ClientApiService] teléfono vacío, no se puede actualizar');
        return {
          'success': false,
          'message': 'El teléfono es obligatorio',
        };
      }

      if (direccion == null || direccion.isEmpty) {
        print('❌ [ClientApiService] dirección vacía, no se puede actualizar');
        return {
          'success': false,
          'message': 'La dirección es obligatoria',
        };
      }

      // Construir el body con campos obligatorios
      final Map<String, dynamic> body = {
        'idCliente': idCliente.toString(),
        'telefono': telefono.trim(),
        'direccion': direccion.trim(),
        'idPrepaga': idPrepaga.trim(),
      };

      print('🔄 [ClientApiService] Body completo: ${jsonEncode(body)}');
      print('🔄 [ClientApiService] ID Cliente en body: ${body['idCliente']}');

      final url = Uri.parse('$_baseUrl/app/put_modificar_usuario');
      final requestBody = jsonEncode(body);
      print('🔄 [ClientApiService] JSON a enviar: $requestBody');
      
      final response = await http.put(
        url,
        headers: {
          'Authorization': _getBasicAuth(),
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('🔄 [ClientApiService] Status Code: ${response.statusCode}');
      print('🔄 [ClientApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          print('✅ [ClientApiService] Datos actualizados exitosamente');
          print('✅ [ClientApiService] Mensaje: ${responseData['mensaje']}');
          return {
            'success': true,
            'message': responseData['mensaje'] ?? 'Datos actualizados correctamente',
            'id_cliente': responseData['id_cliente'],
          };
        } else {
          print('⚠️ [ClientApiService] Respuesta no indica éxito');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Error al actualizar datos',
          };
        }
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        print('❌ [ClientApiService] Error 400: ${responseData['description']}');
        return {
          'success': false,
          'message': responseData['description'] ?? 'Parámetros inválidos',
        };
      } else {
        print('🚨 [ClientApiService] Error en la API: ${response.statusCode}');
        print('🚨 [ClientApiService] Mensaje: ${response.body}');
        return {
          'success': false,
          'message': 'Error al actualizar datos: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🚨 [ClientApiService] Error al actualizar datos del cliente: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
} 