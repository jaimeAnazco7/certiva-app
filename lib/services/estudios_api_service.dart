import 'package:http/http.dart' as http;
import 'dart:convert';

class EstudiosApiService {
  static const String _baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
  static const String _username = 'CERTIVA_APP';
  static const String _password = 'CerTiva2028*';

  // Obtener credenciales de autenticación
  static String _getBasicAuth() {
    final String rawAuth = '${Uri.encodeComponent(_username)}:${Uri.encodeComponent(_password)}';
    return 'Basic ' + base64Encode(utf8.encode(rawAuth));
  }

  // Obtener estudios de un cliente por ID
  static Future<Map<String, dynamic>> getEstudiosCliente(int idCliente) async {
    print('🔬 [EstudiosApiService] Consultando estudios para idCliente: $idCliente');
    print('🔬 [EstudiosApiService] URL: $_baseUrl/app/get_estudios_cliente/$idCliente');
    
    try {
      final url = Uri.parse('$_baseUrl/app/get_estudios_cliente/$idCliente');
      final response = await http.get(
        url,
        headers: {
          'Authorization': _getBasicAuth(),
          'Content-Type': 'application/json',
        },
      );

      print('🔬 [EstudiosApiService] Status Code: ${response.statusCode}');
      print('🔬 [EstudiosApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['estudios'] != null && 
            responseData['estudios'] is List) {
          
          print('✅ [EstudiosApiService] Estudios encontrados: ${responseData['estudios'].length}');
          
          return {
            'success': true,
            'estudios': responseData['estudios'],
            'message': 'Estudios obtenidos exitosamente',
          };
        } else {
          print('❌ [EstudiosApiService] No hay estudios en la respuesta');
          return {
            'success': false,
            'estudios': [],
            'message': 'No se encontraron estudios',
          };
        }
      } else if (response.statusCode == 404) {
        print('❌ [EstudiosApiService] No se encontraron estudios (404)');
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'estudios': [],
          'message': responseData['message'] ?? 'No se encontraron estudios para este cliente',
        };
      } else {
        print('🚨 [EstudiosApiService] Error en la API: ${response.statusCode}');
        return {
          'success': false,
          'estudios': [],
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🚨 [EstudiosApiService] Error al consultar estudios: $e');
      return {
        'success': false,
        'estudios': [],
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Verificar si un cliente tiene estudios
  static Future<bool> hasEstudios(int idCliente) async {
    final result = await getEstudiosCliente(idCliente);
    return result['success'] == true && (result['estudios'] as List).isNotEmpty;
  }

  // Obtener solo la lista de estudios
  static Future<List<Map<String, dynamic>>> getEstudiosList(int idCliente) async {
    final result = await getEstudiosCliente(idCliente);
    if (result['success'] == true) {
      return List<Map<String, dynamic>>.from(result['estudios']);
    }
    return [];
  }
}