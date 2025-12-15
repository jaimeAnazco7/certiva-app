import 'package:http/http.dart' as http;
import 'dart:convert';

class PostAuthService {
  static const String _baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
  static const String _username = 'CERTIVA_APP';
  static const String _password = 'CerTiva2028*';

  // Obtener credenciales de autenticación
  static String _getBasicAuth() {
    final String rawAuth = '${Uri.encodeComponent(_username)}:${Uri.encodeComponent(_password)}';
    return 'Basic ' + base64Encode(utf8.encode(rawAuth));
  }

  // Verificar si el email está registrado y obtener id_cliente
  static Future<Map<String, dynamic>> verifyEmailAndGetClientId(String email) async {
    print('🌐 [PostAuthService] Verificando email: $email');
    print('🌐 [PostAuthService] URL: $_baseUrl/app/post_autenticacion');
    
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

      print('🌐 [PostAuthService] Status Code: ${response.statusCode}');
      print('🌐 [PostAuthService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          print('✅ [PostAuthService] Email verificado exitosamente');
          print('✅ [PostAuthService] ID Cliente: ${responseData['id_cliente']}');
          
          return {
            'success': true,
            'id_cliente': responseData['id_cliente'],
            'mensaje': responseData['mensaje'],
          };
        } else {
          print('❌ [PostAuthService] Email no verificado');
          return {
            'success': false,
            'error': 'Email no verificado',
          };
        }
      } else if (response.statusCode == 404) {
        print('❌ [PostAuthService] Email no registrado (404)');
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'error': 'Correo no registrado',
          'message': responseData['message'] ?? 'Debe registrarse primero para ingresar con este correo',
        };
      } else {
        print('🚨 [PostAuthService] Error en la API: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🚨 [PostAuthService] Error al verificar email: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Verificar si un email está registrado (método simplificado)
  static Future<bool> isEmailRegistered(String email) async {
    final result = await verifyEmailAndGetClientId(email);
    return result['success'] == true;
  }

  // Obtener solo el id_cliente de un email
  static Future<int?> getClientIdByEmail(String email) async {
    final result = await verifyEmailAndGetClientId(email);
    if (result['success'] == true) {
      return result['id_cliente'] as int?;
    }
    return null;
  }
}