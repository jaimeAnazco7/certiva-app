import '../models/consultation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_service.dart';

class ConsultationService {
  static final ConsultationService _instance = ConsultationService._internal();
  factory ConsultationService() => _instance;
  ConsultationService._internal();

  // Datos de ejemplo para simular la API
  final List<Consultation> _mockConsultations = [
    Consultation(
      id: '1',
      specialty: 'Oftalmología',
      doctor: 'Dr. Juan José Ramírez',
      branch: 'Óptica Valemar - Asunción',
      date: '28/07/2025',
      time: '13:00',
      status: 'scheduled',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Consultation(
      id: '2',
      specialty: 'Clínica Médica',
      doctor: 'Dra. Magali Reitas',
      branch: 'Certiva - Villa Morra',
      date: '15/07/2025',
      time: '10:00',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Consultation(
      id: '3',
      specialty: 'Cardiología',
      doctor: 'Dr. Carlos Mendoza',
      branch: 'Certiva - Villa Morra',
      date: '20/07/2025',
      time: '16:00',
      status: 'cancelled',
      notes: 'Cancelada por el paciente',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Obtener agenda del cliente desde la API REAL
  Future<List<Consultation>> getAgendaFromAPI(int idCliente) async {
    try {
      const String baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
      final String endpoint = '/app/get_agenda/$idCliente';
      
      print('📅 [DEBUG] Obteniendo agenda para idCliente: $idCliente');
      print('📅 [DEBUG] URL: $baseUrl$endpoint');
      
      // Credenciales de autenticación Basic Auth
      const String username = 'CERTIVA_APP';
      const String password = 'CerTiva2028*';
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
      );

      print('📅 [DEBUG] Response status: ${response.statusCode}');
      print('📅 [DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> agendas = data['agendas'] ?? [];
        
        print('📅 [DEBUG] Agendas encontradas: ${agendas.length}');
        
        // Mapear datos de la API al modelo Consultation
        return agendas.map((agenda) {
          // Convertir estado de la API a estado del modelo
          String status;
          switch (agenda['estado']?.toString().toUpperCase()) {
            case 'CERRADO':
              status = 'completed';
              break;
            case 'RESERVADO':
              status = 'scheduled';
              break;
            case 'PENDIENTE':
              status = 'pending';
              break;
            default:
              status = 'scheduled';
          }
          
          // Formatear fecha de "2025-07-08" a "08/07/2025"
          String formattedDate = agenda['fecha_reserva'] ?? '';
          if (formattedDate.isNotEmpty) {
            try {
              final parts = formattedDate.split('-');
              if (parts.length == 3) {
                formattedDate = '${parts[2]}/${parts[1]}/${parts[0]}';
              }
            } catch (e) {
              print('📅 [ERROR] Error al formatear fecha: $e');
            }
          }
          
          return Consultation(
            id: agenda['cod']?.toString() ?? '',
            specialty: agenda['nombre_especialidad'] ?? '',
            doctor: agenda['nombre_prestador'] ?? '',
            branch: agenda['nombre_sucursal'] ?? '',
            date: formattedDate,
            time: agenda['hora_turno'] ?? '',
            status: status,
            notes: null,
            createdAt: DateTime.now(), // La API no devuelve fecha de creación
          );
        }).toList();
      } else if (response.statusCode == 404) {
        print('📅 [DEBUG] No hay turnos para este cliente (404)');
        return [];
      } else {
        print('📅 [ERROR] Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('📅 [ERROR] Excepción en getAgendaFromAPI: $e');
      return [];
    }
  }

  // Obtener todas las consultas del usuario (ACTUALIZADO para usar API real)
  Future<List<Consultation>> getAllConsultations() async {
    try {
      // Obtener el usuario actual
      final currentUser = UserService.getCurrentUser();
      
      if (currentUser == null) {
        print('📅 [ERROR] No hay usuario logueado');
        return [];
      }
      
      // Verificar si tiene idCliente (viene de la API)
      if (currentUser.idCliente == null) {
        print('📅 [WARNING] Usuario sin idCliente, usando datos mock');
        return _mockConsultations;
      }
      
      print('📅 [DEBUG] Obteniendo agenda para usuario: ${currentUser.email} (ID: ${currentUser.idCliente})');
      
      // Llamar a la API real
      return await getAgendaFromAPI(currentUser.idCliente!);
    } catch (e) {
      print('📅 [ERROR] Error en getAllConsultations: $e');
      // En caso de error, retornar datos mock como fallback
      return _mockConsultations;
    }
  }

  // Obtener consultas por estado (ACTUALIZADO para usar API real)
  Future<List<Consultation>> getConsultationsByStatus(String status) async {
    try {
      // Obtener todas las consultas de la API
      final allConsultations = await getAllConsultations();
      
      // Filtrar por estado
      return allConsultations.where((consultation) => consultation.status == status).toList();
    } catch (e) {
      print('📅 [ERROR] Error en getConsultationsByStatus: $e');
      return [];
    }
  }

  // Crear una nueva consulta
  Future<Consultation> createConsultation({
    required String specialty,
    required String doctor,
    required String branch,
    required String date,
    required String time,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final newConsultation = Consultation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      specialty: specialty,
      doctor: doctor,
      branch: branch,
      date: date,
      time: time,
      status: 'scheduled',
      createdAt: DateTime.now(),
    );

    _mockConsultations.add(newConsultation);
    return newConsultation;
  }

  // Cancelar una consulta
  Future<bool> cancelConsultation(String consultationId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _mockConsultations.indexWhere((c) => c.id == consultationId);
    if (index != -1) {
      _mockConsultations[index] = _mockConsultations[index].copyWith(
        status: 'cancelled',
        notes: reason,
      );
      return true;
    }
    return false;
  }

  // Marcar consulta como completada
  Future<bool> completeConsultation(String consultationId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _mockConsultations.indexWhere((c) => c.id == consultationId);
    if (index != -1) {
      _mockConsultations[index] = _mockConsultations[index].copyWith(
        status: 'completed',
      );
      return true;
    }
    return false;
  }

  // Obtener especialidades disponibles desde la API
  Future<List<Map<String, dynamic>>> getSpecialties() async {
    try {
      const String baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
      const String endpoint = '/app/get_especialidad';
      
      // Credenciales de autenticación Basic Auth
      const String username = 'CERTIVA_APP';
      const String password = 'CerTiva2028*';
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
      );

      print('🩺 [DEBUG] Especialidades - Response status: ${response.statusCode}');
      print('🩺 [DEBUG] Especialidades - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> especialidades = data['especialidades'] ?? [];
        
        print('🩺 [DEBUG] Especialidades encontradas: ${especialidades.length}');
        
        // Convertir a lista de Map con cod_especialidad y descripcion_especialidad
        return especialidades.map((especialidad) => {
          'cod_especialidad': especialidad['cod_especialidad'],
          'descripcion_especialidad': especialidad['descripcion_especialidad'],
        }).toList().cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        // No hay especialidades registradas
        print('🩺 [DEBUG] No hay especialidades (404)');
        return [];
      } else {
        print('🩺 [ERROR] Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener especialidades: ${response.statusCode}');
      }
    } catch (e) {
      print('🩺 [ERROR] Excepción en getSpecialties: $e');
      // Retornar lista vacía en caso de error
      return [];
    }
  }

  // Obtener médicos/prestadores por especialidad desde la API
  Future<List<Map<String, dynamic>>> getDoctorsBySpecialty(int codEspecialidad, String nombreEspecialidad) async {
    try {
      const String baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
      final String endpoint = '/app/get_prestadores/$codEspecialidad';
      
      // Credenciales de autenticación Basic Auth
      const String username = 'CERTIVA_APP';
      const String password = 'CerTiva2028*';
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
      );

      print('👨‍⚕️ [DEBUG] Prestadores - Response status: ${response.statusCode}');
      print('👨‍⚕️ [DEBUG] Prestadores - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> prestadores = data['prestadores'] ?? [];
        
        print('👨‍⚕️ [DEBUG] Prestadores encontrados: ${prestadores.length}');
        
        // Convertir a lista de Map con cod_prestador, nombre_prestador y especialidad
        return prestadores.map((prestador) => {
          'cod_prestador': prestador['cod_prestador'],
          'nombre_prestador': prestador['nombre_prestador'],
          'especialidad': nombreEspecialidad, // Agregamos la especialidad
        }).toList().cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        // No hay prestadores para esta especialidad
        print('👨‍⚕️ [DEBUG] No hay prestadores para esta especialidad (404)');
        return [];
      } else {
        print('👨‍⚕️ [ERROR] Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener prestadores: ${response.statusCode}');
      }
    } catch (e) {
      print('👨‍⚕️ [ERROR] Excepción en getDoctorsBySpecialty: $e');
      return [];
    }
  }

  // Obtener todos los doctores disponibles de TODAS las especialidades
  // Elimina duplicados y agrupa especialidades por médico
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      print('👨‍⚕️ [DEBUG] Iniciando carga de TODOS los doctores...');
      
      // Primero obtener todas las especialidades
      final especialidades = await getSpecialties();
      
      if (especialidades.isEmpty) {
        print('👨‍⚕️ [DEBUG] No hay especialidades disponibles');
        return [];
      }
      
      // Map para agrupar médicos únicos por cod_prestador
      Map<int, Map<String, dynamic>> uniqueDoctors = {};
      
      // Para cada especialidad, obtener sus médicos
      for (var especialidad in especialidades) {
        final codEspecialidad = especialidad['cod_especialidad'];
        final nombreEspecialidad = especialidad['descripcion_especialidad'];
        
        print('👨‍⚕️ [DEBUG] Obteniendo médicos de: $nombreEspecialidad (cod: $codEspecialidad)');
        
        final doctors = await getDoctorsBySpecialty(codEspecialidad, nombreEspecialidad);
        
        // Agrupar médicos eliminando duplicados
        for (var doctor in doctors) {
          final codPrestador = doctor['cod_prestador'];
          
          if (uniqueDoctors.containsKey(codPrestador)) {
            // El médico ya existe, agregar la nueva especialidad a su lista
            List<String> especialidades = List<String>.from(uniqueDoctors[codPrestador]!['especialidades']);
            if (!especialidades.contains(nombreEspecialidad)) {
              especialidades.add(nombreEspecialidad);
              uniqueDoctors[codPrestador]!['especialidades'] = especialidades;
            }
          } else {
            // Nuevo médico, crear entrada con lista de especialidades
            uniqueDoctors[codPrestador] = {
              'cod_prestador': codPrestador,
              'nombre_prestador': doctor['nombre_prestador'],
              'especialidades': [nombreEspecialidad], // Lista de especialidades
              'especialidad': nombreEspecialidad, // Mantener compatibilidad (primera especialidad)
            };
          }
        }
      }
      
      print('👨‍⚕️ [DEBUG] Total de médicos únicos: ${uniqueDoctors.length}');
      
      return uniqueDoctors.values.toList();
    } catch (e) {
      print('👨‍⚕️ [ERROR] Error al obtener todos los doctores: $e');
      return [];
    }
  }

  // Obtener turnos disponibles desde la API (ACTUALIZADO: Query Parameters)
  Future<List<Map<String, dynamic>>> getTurnosDisponibles({
    required String fecha,      // OBLIGATORIO: Formato "DD-MM-YYYY" (ej: "26-09-2025")
    int? prestador,             // cod_prestador (null = sin filtro)
    int? especialidad,          // cod_especialidad (null = sin filtro)
    int? sucursal,              // cod_sucursal (null = sin filtro)
  }) async {
    try {
      const String baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
      const String endpoint = '/app/get_turnos_disponibles';
      
      // Construir URL con Query Parameters
      final uri = Uri.parse('$baseUrl$endpoint');
      final queryParams = <String, String>{
        'FECHA': fecha, // OBLIGATORIO
      };
      
      // Solo agregar parámetros que no sean null (sin filtro)
      if (prestador != null) {
        queryParams['PRESTADOR'] = prestador.toString();
      }
      if (especialidad != null) {
        queryParams['ESPECIALIDAD'] = especialidad.toString();
      }
      if (sucursal != null) {
        queryParams['SUCURSAL'] = sucursal.toString();
      }
      
      final url = uri.replace(queryParameters: queryParams).toString();
      
      print('📅 [DEBUG] Obteniendo turnos con Query Parameters...');
      print('📅 [DEBUG] URL: $url');
      print('📅 [DEBUG] Fecha: $fecha, Prestador: $prestador, Especialidad: $especialidad, Sucursal: $sucursal');
      
      // Credenciales de autenticación Basic Auth
      const String username = 'CERTIVA_APP';
      const String password = 'CerTiva2028*';
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
      );

      print('📅 [DEBUG] Response status: ${response.statusCode}');
      print('📅 [DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> turnos = data['turnos'] ?? [];
        
        print('📅 [DEBUG] Turnos encontrados: ${turnos.length}');
        
        return turnos.map((turno) => {
          'fecha': turno['fecha'],
          'hora_disponible': turno['hora_disponible'],
          'profesional': turno['profesional'],
          'raz_soc_nombre': turno['raz_soc_nombre'],
          'cod_sucursal': turno['cod_sucursal'],
          'descripcion_sucursal': turno['descripcion_sucursal'],
          'cod_box': turno['cod_box'],
          'id_det_aux': turno['id_det_aux'], // IMPORTANTE: Para reservar
          'esp_id_especialidad': turno['esp_id_especialidad'],
          'descripcion_especialidad': turno['descripcion_especialidad'],
          'estado': turno['estado'],
        }).toList().cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        print('📅 [DEBUG] No hay turnos disponibles (404)');
        return [];
      } else if (response.statusCode == 500) {
        // Nuevo error: Fecha obligatoria
        print('📅 [ERROR] Error 500: Fecha obligatoria');
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Error: ${errorData['message'] ?? 'Fecha obligatoria'}');
      } else {
        print('📅 [ERROR] Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener turnos: ${response.statusCode}');
      }
    } catch (e) {
      print('📅 [ERROR] Excepción en getTurnosDisponibles: $e');
      return [];
    }
  }

  // Obtener sucursales disponibles desde la API
  Future<List<Map<String, dynamic>>> getBranches() async {
    try {
      const String baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
      const String endpoint = '/app/get_sucursales';
      
      // Credenciales de autenticación Basic Auth
      const String username = 'CERTIVA_APP';
      const String password = 'CerTiva2028*';
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
      );

      print('🏥 [DEBUG] Response status: ${response.statusCode}');
      print('🏥 [DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> sucursales = data['sucursales'] ?? [];
        
        print('🏥 [DEBUG] Sucursales encontradas: ${sucursales.length}');
        
        // Convertir a lista de Map con cod_sucursal y descripcion_sucursal
        return sucursales.map((sucursal) => {
          'cod_sucursal': sucursal['cod_sucursal'],
          'descripcion_sucursal': sucursal['descripcion_sucursal'],
        }).toList().cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        // No hay sucursales registradas
        print('🏥 [DEBUG] No hay sucursales (404)');
        return [];
      } else {
        print('🏥 [ERROR] Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener sucursales: ${response.statusCode}');
      }
    } catch (e) {
      print('🏥 [ERROR] Excepción en getBranches: $e');
      // Retornar lista vacía en caso de error
      return [];
    }
  }

  // Obtener horarios disponibles
  Future<List<String>> getAvailableTimes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      '8:00', '9:00', '10:00', '11:00', '12:00', '13:00', 
      '14:00', '15:00', '16:00', '17:00', '18:00', '19:00'
    ];
  }

  // Verificar disponibilidad de horario
  Future<bool> isTimeAvailable(String date, String time) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Simular horarios ocupados
    final unavailableTimes = ['12:00', '13:00', '16:00', '19:00'];
    return !unavailableTimes.contains(time);
  }

  // Obtener citas disponibles por doctor
  Future<List<Map<String, dynamic>>> getAppointmentsByDoctor(String doctor) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Simular citas disponibles para los próximos días
    final now = DateTime.now();
    final appointments = <Map<String, dynamic>>[];
    
    // Generar citas para los próximos 7 días
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final monthName = _getMonthName(date.month);
      final day = date.day;
      
      // Crear el doctor seleccionado con su información
      final doctorInfo = {
        'name': doctor,
        'specialty': _getDoctorSpecialty(doctor),
        'consultationDays': _getConsultationDays(doctor),
      };
      
      appointments.add({
        'date': '$dayName $day de $monthName',
        'doctors': [doctorInfo], // Solo el doctor seleccionado
      });
    }
    
    return appointments;
  }

  String _getDoctorSpecialty(String doctorName) {
    // Simular especialidad por doctor
    if (doctorName.contains('Johanna')) {
      return 'Cardiología';
    } else if (doctorName.contains('Carlos')) {
      return 'Oftalmología';
    } else if (doctorName.contains('Ana')) {
      return 'Clínica Médica';
    } else if (doctorName.contains('Ramírez')) {
      return 'Oftalmología';
    } else if (doctorName.contains('Reitas')) {
      return 'Clínica Médica';
    } else if (doctorName.contains('Mendoza')) {
      return 'Cardiología';
    } else {
      return 'Medicina General';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 
                   'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return months[month - 1];
  }

  // Obtener citas disponibles por especialidad (MOCK - No se usa actualmente)
  Future<List<Map<String, dynamic>>> getAppointmentsBySpecialty(String specialty) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Este método ya no se usa, se reemplazó por el filtrado directo de médicos
    // Retornamos lista vacía por ahora
    return [];
    
    /* CÓDIGO COMENTADO - Por si se necesita en el futuro
    // Simular citas disponibles para los próximos días
    final now = DateTime.now();
    final appointments = <Map<String, dynamic>>[];
    
    // Generar citas para los próximos 7 días
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final monthName = _getMonthName(date.month);
      final day = date.day;
      
      appointments.add({
        'date': '$dayName $day de $monthName',
        'doctors': [],
      });
    }
    
    return appointments;
    */
  }

  // Obtener horarios específicos de un doctor
  Future<Map<String, dynamic>> getDoctorSchedule(String doctor, String date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Horarios disponibles (8:00 a 19:00)
    final availableTimes = ['8:00', '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00'];
    
    // Simular algunos horarios ocupados
    final unavailableTimes = <String>[];
    if (doctor.contains('Johanna')) {
      unavailableTimes.addAll(['12:00', '13:00', '16:00', '19:00']);
    } else if (doctor.contains('Carlos')) {
      unavailableTimes.addAll(['9:00', '11:00', '15:00', '17:00']);
    } else {
      unavailableTimes.addAll(['8:00', '10:00', '14:00', '18:00']);
    }
    
    return {
      'availableTimes': availableTimes,
      'unavailableTimes': unavailableTimes,
    };
  }

  // Agendar turno (NUEVA API)
  Future<Map<String, dynamic>> agendarTurno({
    required String fechaReserva,    // "25/09/2025 15:00"
    required int idCliente,          // ID del cliente
    required int idPersonaProf,      // ID del profesional
    required int idDetAux,           // ID del turno (de get_turnos_disponibles)
    required int idBox,              // ID del box
    required int idSucursal,         // ID de la sucursal
    String? observacion,             // Comentario opcional
  }) async {
    try {
      const String baseUrl = 'https://kove.app.kove.com.py/ords/certiva_situs';
      const String endpoint = '/app/post_agendar_turno';
      
      // Credenciales de autenticación Basic Auth
      const String username = 'CERTIVA_APP';
      const String password = 'CerTiva2028*';
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      
      // Construir el body JSON
      final Map<String, dynamic> requestBody = {
        'fecha_reserva': fechaReserva,
        'id_cliente': idCliente,
        'id_persona_prof': idPersonaProf,
        'id_det_aux': idDetAux,
        'id_box': idBox,
        'id_sucursal': idSucursal,
      };
      
      // Agregar observación si existe
      if (observacion != null && observacion.isNotEmpty) {
        requestBody['observacion'] = observacion;
      }
      
      print('📅 [DEBUG] Agendando turno...');
      print('📅 [DEBUG] URL: $baseUrl$endpoint');
      print('📅 [DEBUG] Body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: json.encode(requestBody),
      );

      print('📅 [DEBUG] Response status: ${response.statusCode}');
      print('📅 [DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Éxito
        final Map<String, dynamic> data = json.decode(response.body);
        print('📅 [DEBUG] Turno agendado exitosamente');
        
        return {
          'success': true,
          'status': data['status'] ?? 'success',
          'mensaje': data['mensaje'] ?? 'Turno agendado correctamente',
          'data': data,
        };
      } else if (response.statusCode == 404) {
        // Error de validación
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('📅 [ERROR] Error 404: ${errorData['message']}');
        
        return {
          'success': false,
          'error': 'validation',
          'code': errorData['code'] ?? '404',
          'message': errorData['message'] ?? 'Error de validación',
          'description': errorData['description'] ?? 'Validación de proceso',
        };
      } else {
        // Otros errores
        print('📅 [ERROR] Error ${response.statusCode}: ${response.body}');
        
        return {
          'success': false,
          'error': 'server',
          'code': response.statusCode.toString(),
          'message': 'Error del servidor: ${response.statusCode}',
          'description': response.body,
        };
      }
    } catch (e) {
      print('📅 [ERROR] Excepción en agendarTurno: $e');
      
      return {
        'success': false,
        'error': 'network',
        'message': 'Error de conexión: $e',
        'description': 'No se pudo conectar con el servidor',
      };
    }
  }

  String _getConsultationDays(String doctorName) {
    // Simular días de consulta por doctor
    if (doctorName.contains('Johanna')) {
      return 'Lunes, miércoles y viernes';
    } else if (doctorName.contains('Carlos')) {
      return 'Martes y jueves';
    } else if (doctorName.contains('Ana')) {
      return 'Lunes a viernes';
    } else {
      return 'Lunes, miércoles y viernes';
    }
  }
} 