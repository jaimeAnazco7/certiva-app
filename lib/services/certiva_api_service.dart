import 'dart:convert';
import 'package:http/http.dart' as http;

class CertivaApiService {
  static const String baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
  static const String username = 'CERTIVA_APP';
  static const String password = 'CerTiva2028*';

  // Codificar credenciales para Basic Auth
  static String get _basicAuth {
    final credentials = '$username:$password';
    final bytes = utf8.encode(credentials);
    final base64Credentials = base64.encode(bytes);
    return 'Basic $base64Credentials';
  }

  static Future<Map<String, dynamic>> registrarCliente({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String cedula,
    required int prepaga,
    required String direccion,
    required String telefono,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/app/registrar_cliente');
      
      final body = {
        'email': email,
        'password': password,
        'nombre': nombre,
        'apellido': apellido,
        'autenticacion': 'CORREO',
        'cedula': cedula,
        'prepaga': prepaga,
        'direccion': direccion,
        'telefono': telefono,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _basicAuth,
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Registro exitoso
        return {
          'success': true,
          'data': responseData,
          'message': 'Cliente registrado exitosamente: ${responseData['nombre_cliente']}',
        };
      } else {
        // Error del servidor
        return {
          'success': false,
          'error': responseData['description'] ?? 'Error desconocido',
          'code': responseData['code'] ?? '500',
        };
      }
    } catch (e) {
      // Error de conexión o parsing
      return {
        'success': false,
        'error': 'Error de conexión: $e',
        'code': 'CONNECTION_ERROR',
      };
    }
  }
} 

extension CertivaApiServiceExtras on CertivaApiService {
  static Future<Map<String, dynamic>> getPrepagasActivasRaw() async {
    try {
      final url = Uri.parse('${CertivaApiService.baseUrl}/app/registrar_cliente');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': CertivaApiService._basicAuth,
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': data};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> getPrepagasActivas() async {
    final raw = await getPrepagasActivasRaw();
    if (raw['success'] == true) {
      final List prepagas = raw['data']['prepagas'] ?? [];
      return prepagas.cast<Map<String, dynamic>>();
    }
    return [];
  }
} 