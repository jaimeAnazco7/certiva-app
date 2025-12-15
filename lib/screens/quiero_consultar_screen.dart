import 'package:flutter/material.dart';
import '../services/consultation_service.dart';
import '../services/user_service.dart';
import 'consulta_agendada_screen.dart';

class QuieroConsultarScreen extends StatefulWidget {
  const QuieroConsultarScreen({Key? key}) : super(key: key);

  @override
  State<QuieroConsultarScreen> createState() => _QuieroConsultarScreenState();
}

class _QuieroConsultarScreenState extends State<QuieroConsultarScreen> {
  final ConsultationService _consultationService = ConsultationService();
  
  String selectedSpecialty = '';
  int selectedSpecialtyCode = 0;
  String selectedDoctor = '';
  int selectedDoctorCode = 0;
  String selectedBranch = '';
  int selectedBranchCode = 0;
  String selectedDate = '';
  String selectedTime = '';
  
  bool showSpecialtyDropdown = false;
  bool showDoctorDropdown = false;
  bool showBranchDropdown = false;
  bool showDatePicker = false;
  bool isLoading = false;
  bool showResults = false; // Controlar si mostrar sección de resultados
  
  List<Map<String, dynamic>> specialties = [];
  List<Map<String, dynamic>> doctors = []; // Lista filtrada de médicos
  List<Map<String, dynamic>> allDoctors = []; // Lista completa de TODOS los médicos
  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> availableTurnos = []; // Cards de turnos disponibles
  List<String> selectedTimes = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final specialtiesData = await _consultationService.getSpecialties();
      final branchesData = await _consultationService.getBranches();
      final doctorsData = await _consultationService.getAllDoctors(); // Cargar TODOS los doctores

      print('🏥 [DEBUG] Especialidades cargadas: ${specialtiesData.length}');
      print('🏥 [DEBUG] Sucursales cargadas: ${branchesData.length}');
      print('🩺 [DEBUG] TODOS los doctores cargados: ${doctorsData.length}');

      setState(() {
        specialties = specialtiesData;
        branches = branchesData;
        allDoctors = doctorsData; // Guardar TODOS los médicos
        doctors = doctorsData; // Para el dropdown de médicos
        isLoading = false;
        showResults = false; // NO mostrar resultados al inicio
      });
    } catch (e) {
      print('🏥 [ERROR] Error al cargar datos: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Aplicar filtros incrementales y cargar turnos disponibles (ACTUALIZADO)
  Future<void> _aplicarFiltros() async {
    print('🔍 [DEBUG] ========================================');
    print('🔍 [DEBUG] Aplicando filtros...');
    print('🔍 [DEBUG] Especialidad: $selectedSpecialtyCode ($selectedSpecialty)');
    print('🔍 [DEBUG] Médico: $selectedDoctorCode ($selectedDoctor)');
    print('🔍 [DEBUG] Sucursal: $selectedBranchCode ($selectedBranch)');
    print('🔍 [DEBUG] Fecha: $selectedDate');
    
    // Usar fecha de hoy por defecto si no hay fecha seleccionada
    String fechaParaAPI = selectedDate;
    if (fechaParaAPI.isEmpty) {
      // Formatear fecha de hoy como DD-MM-YYYY
      final hoy = DateTime.now();
      fechaParaAPI = '${hoy.day.toString().padLeft(2, '0')}-${hoy.month.toString().padLeft(2, '0')}-${hoy.year}';
      print('🔍 [DEBUG] Usando fecha de hoy por defecto: $fechaParaAPI');
    }
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Llamar API con los filtros seleccionados (NUEVA API con Query Parameters)
      final turnos = await _consultationService.getTurnosDisponibles(
        fecha: fechaParaAPI, // Fecha seleccionada o fecha de hoy por defecto
        prestador: selectedDoctorCode > 0 ? selectedDoctorCode : null, // null = sin filtro
        especialidad: selectedSpecialtyCode > 0 ? selectedSpecialtyCode : null, // null = sin filtro
        sucursal: selectedBranchCode > 0 ? selectedBranchCode : null, // null = sin filtro
      );
      
      print('🔍 [DEBUG] Turnos recibidos: ${turnos.length} para fecha: $fechaParaAPI');
      
      // Agrupar turnos por médico + fecha
      final cardsData = _agruparTurnosPorMedicoYFecha(turnos);
      
      setState(() {
        availableTurnos = cardsData;
        showResults = true;
        isLoading = false;
      });
      
      print('🔍 [DEBUG] Cards generados: ${cardsData.length}');
      print('🔍 [DEBUG] ========================================');
      
    } catch (e) {
      print('🔍 [ERROR] Error al aplicar filtros: $e');
      setState(() {
        isLoading = false;
        showResults = false;
      });
      
      // Manejo específico del error 500 (fecha obligatoria)
      String errorMessage = 'Error al cargar turnos';
      if (e.toString().contains('Fecha obligatoria')) {
        errorMessage = 'La fecha es obligatoria para buscar turnos';
      } else if (e.toString().contains('Error 500')) {
        errorMessage = 'Error del servidor: Fecha obligatoria';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  // Agrupar turnos por médico, fecha, especialidad y sucursal
  List<Map<String, dynamic>> _agruparTurnosPorMedicoYFecha(List<Map<String, dynamic>> turnos) {
    Map<String, Map<String, dynamic>> agrupados = {};
    
    for (var turno in turnos) {
      // Clave única: fecha|medico|especialidad|sucursal
      String key = "${turno['fecha']}|${turno['profesional']}|${turno['esp_id_especialidad']}|${turno['cod_sucursal']}";
      
      if (!agrupados.containsKey(key)) {
        // Crear nuevo card
        agrupados[key] = {
          'fecha': turno['fecha'],
          'cod_prestador': turno['profesional'],
          'nombre_prestador': turno['raz_soc_nombre'],
          'cod_especialidad': turno['esp_id_especialidad'],
          'descripcion_especialidad': turno['descripcion_especialidad'],
          'cod_sucursal': turno['cod_sucursal'],
          'descripcion_sucursal': turno['descripcion_sucursal'],
          'horarios': [], // Lista de horarios disponibles
          'turnos': [], // Lista completa de turnos (con id_det_aux)
        };
      }
      
      // Agregar horario al card
      agrupados[key]!['horarios'].add(turno['hora_disponible']);
      agrupados[key]!['turnos'].add(turno); // Guardar turno completo
    }
    
    return agrupados.values.toList();
  }
  
  // Filtrar médicos por especialidad seleccionada (para el dropdown)
  void _filterDoctorsBySpecialty(String especialidad) {
    print('👨‍⚕️ [DEBUG] Filtrando médicos por especialidad: $especialidad');
    
    if (especialidad.isEmpty) {
      setState(() {
        doctors = allDoctors;
      });
      print('👨‍⚕️ [DEBUG] Mostrando TODOS los médicos: ${doctors.length}');
    } else {
      setState(() {
        doctors = allDoctors.where((doctor) {
          List<String> especialidades = List<String>.from(doctor['especialidades'] ?? [doctor['especialidad']]);
          return especialidades.contains(especialidad);
        }).toList();
      });
      print('👨‍⚕️ [DEBUG] Médicos filtrados: ${doctors.length}');
    }
  }




  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.getCurrentUser();
    final userEmail = currentUser?.email ?? 'Usuario';
    final username = userEmail.contains('@') 
        ? '@${userEmail.split('@')[0]}' 
        : userEmail;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB47EDB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiero consultar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  username,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.person, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header morado extendido
          Container(
            width: double.infinity,
            height: 20,
            color: const Color(0xFFB47EDB),
          ),
          // Contenido principal
          Expanded(
            child: isLoading && specialties.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB47EDB)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando datos...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de filtros
                        _buildFilterSection(),
                        const SizedBox(height: 24),
                        // Sección de resultados
                        if (selectedSpecialty.isNotEmpty || selectedDoctor.isNotEmpty) _buildResultsSection(),
                      ],
                    ),
                  ),
          ),
          // Logo de Certiva al final
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Image.asset(
                'assets/icons/logo_color.png',
                width: 151,
                height: 76,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Especialidad
          _buildFilterField(
            label: 'Especialidad',
            value: selectedSpecialty.isEmpty ? 'Seleccionar especialidad' : selectedSpecialty,
            icon: Icons.keyboard_arrow_down,
            onTap: () {
              setState(() {
                showSpecialtyDropdown = !showSpecialtyDropdown;
                showDoctorDropdown = false;
                showBranchDropdown = false;
              });
            },
          ),
          if (showSpecialtyDropdown) _buildSpecialtyDropdown(),
          
          const SizedBox(height: 16),
          
          // Médico
          _buildFilterField(
            label: 'Médico',
            value: selectedDoctor.isEmpty ? 'Seleccionar médico' : selectedDoctor,
            icon: showDoctorDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            onTap: () {
              print('🩺 [DEBUG] Tap en campo de médico - doctors.length: ${doctors.length}');
              setState(() {
                showDoctorDropdown = !showDoctorDropdown;
                showSpecialtyDropdown = false;
                showBranchDropdown = false;
              });
            },
          ),
          // Botón de prueba
          // ElevatedButton(
          //   onPressed: () {
          //     print('🩺 [DEBUG] Botón de prueba - doctors.length: ${doctors.length}');
          //     setState(() {
          //       showDoctorDropdown = !showDoctorDropdown;
          //     });
          //   },
          //   child: Text('Test Dropdown (${doctors.length} doctores)'),
          // ),
          if (showDoctorDropdown) 
            Container(
              child: Text('DEBUG: Dropdown activo - doctors: ${doctors.length}'),
            ),
          if (showDoctorDropdown) _buildDoctorDropdown(),
          
          const SizedBox(height: 16),
          
          // Sucursal
          _buildFilterField(
            label: 'Sucursal',
            value: selectedBranch.isEmpty ? 'Seleccionar sucursal' : selectedBranch,
            icon: Icons.keyboard_arrow_down,
            onTap: () {
              setState(() {
                showBranchDropdown = !showBranchDropdown;
                showSpecialtyDropdown = false;
                showDoctorDropdown = false;
              });
            },
          ),
          if (showBranchDropdown) _buildBranchDropdown(),
          
          const SizedBox(height: 16),
          
          // Fecha - Horario
          _buildFilterField(
            label: 'Fecha - Horario',
            value: selectedDate.isEmpty ? 'Seleccionar fecha y hora' : '$selectedDate - $selectedTime hs',
            icon: Icons.calendar_today,
            onTap: () {
              // Solo se puede seleccionar si hay un doctor seleccionado
              if (selectedDoctor.isNotEmpty) {
                setState(() {
                  showDatePicker = !showDatePicker;
                  showSpecialtyDropdown = false;
                  showDoctorDropdown = false;
                  showBranchDropdown = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF09D5D6), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: value.contains('Seleccionar') ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                Icon(icon, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDropdown(List<String> options, String selectedValue, Function(String) onSelect) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
      ),
      child: Column(
        children: options.map((option) => InkWell(
          onTap: () => onSelect(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: option == selectedValue 
                  ? const Color(0xFFB47EDB).withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      color: option == selectedValue 
                          ? const Color(0xFFB47EDB)
                          : Colors.grey,
                    ),
                  ),
                ),
                if (option == selectedValue)
                  const Icon(Icons.check, color: Color(0xFFB47EDB), size: 16),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSpecialtyDropdown() {
    print('🩺 [DEBUG] _buildSpecialtyDropdown llamado - specialties.length: ${specialties.length}');
    
    if (specialties.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
        ),
        child: const Text(
          'No hay especialidades disponibles',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
      ),
      child: Column(
        children: specialties.map((specialty) => InkWell(
          onTap: () {
            setState(() {
              selectedSpecialty = specialty['descripcion_especialidad'];
              selectedSpecialtyCode = specialty['cod_especialidad'];
              showSpecialtyDropdown = false;
            });
            // Filtrar médicos por la especialidad seleccionada (para el dropdown)
            _filterDoctorsBySpecialty(specialty['descripcion_especialidad']);
            // Aplicar filtros para cargar turnos
            _aplicarFiltros();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: specialty['descripcion_especialidad'] == selectedSpecialty 
                  ? const Color(0xFFB47EDB).withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    specialty['descripcion_especialidad'],
                    style: TextStyle(
                      fontSize: 14,
                      color: specialty['descripcion_especialidad'] == selectedSpecialty 
                          ? const Color(0xFFB47EDB)
                          : Colors.grey,
                    ),
                  ),
                ),
                if (specialty['descripcion_especialidad'] == selectedSpecialty)
                  const Icon(Icons.check, color: Color(0xFFB47EDB), size: 16),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildDoctorDropdown() {
    print('👨‍⚕️ [DEBUG] _buildDoctorDropdown llamado - doctors.length: ${doctors.length}');
    
    if (doctors.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
        ),
        child: const Text(
          'No hay médicos disponibles',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
      ),
      child: Column(
        children: doctors.map((doctor) {
          // Obtener lista de especialidades
          List<String> especialidades = List<String>.from(doctor['especialidades'] ?? [doctor['especialidad']]);
          String especialidadesText = especialidades.join(', '); // Unir con comas
          
          return InkWell(
            onTap: () {
              setState(() {
                selectedDoctor = doctor['nombre_prestador'];
                selectedDoctorCode = doctor['cod_prestador'];
                showDoctorDropdown = false;
              });
              // Aplicar filtros para cargar turnos
              _aplicarFiltros();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: doctor['nombre_prestador'] == selectedDoctor 
                    ? const Color(0xFFB47EDB).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['nombre_prestador'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: doctor['nombre_prestador'] == selectedDoctor 
                                ? const Color(0xFFB47EDB)
                                : Colors.black,
                          ),
                        ),
                        Text(
                          especialidadesText, // Mostrar TODAS las especialidades
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (doctor['nombre_prestador'] == selectedDoctor)
                    const Icon(Icons.check, color: Color(0xFFB47EDB), size: 16),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBranchDropdown() {
    print('🏥 [DEBUG] _buildBranchDropdown llamado - branches.length: ${branches.length}');
    
    if (branches.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
        ),
        child: const Text(
          'No hay sucursales disponibles',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
      ),
      child: Column(
        children: branches.map((branch) => InkWell(
          onTap: () {
            setState(() {
              selectedBranch = branch['descripcion_sucursal'];
              selectedBranchCode = branch['cod_sucursal'];
              showBranchDropdown = false;
            });
            // Aplicar filtros para cargar turnos
            _aplicarFiltros();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: branch['descripcion_sucursal'] == selectedBranch 
                  ? const Color(0xFFB47EDB).withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    branch['descripcion_sucursal'],
                    style: TextStyle(
                      fontSize: 14,
                      color: branch['descripcion_sucursal'] == selectedBranch 
                          ? const Color(0xFFB47EDB)
                          : Colors.grey,
                    ),
                  ),
                ),
                if (branch['descripcion_sucursal'] == selectedBranch)
                  const Icon(Icons.check, color: Color(0xFFB47EDB), size: 16),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildResultsSection() {
    // No mostrar si showResults es false
    if (!showResults) {
      return const SizedBox.shrink();
    }
    
    // Si está cargando, mostrar indicador
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB47EDB)),
          ),
        ),
      );
    }
    
    // Si no hay turnos disponibles
    if (availableTurnos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No hay turnos disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Intenta con otros filtros',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar cards de turnos disponibles
    return Column(
      children: availableTurnos.map((cardData) {
        return _buildTurnoCard(cardData);
      }).toList(),
    );
  }

  // Construir card de turno disponible
  Widget _buildTurnoCard(Map<String, dynamic> cardData) {
    final int cantidadHorarios = (cardData['horarios'] as List).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Médico
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFB47EDB).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFFB47EDB), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardData['nombre_prestador'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          cardData['descripcion_especialidad'],
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
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Fecha
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Color(0xFF09D5D6)),
                  const SizedBox(width: 8),
                  Text(
                    cardData['fecha'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Sucursal
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Color(0xFF09D5D6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cardData['descripcion_sucursal'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Horarios disponibles
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Color(0xFF09D5D6)),
                  const SizedBox(width: 8),
                  Text(
                    '$cantidadHorarios ${cantidadHorarios == 1 ? "horario disponible" : "horarios disponibles"}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB47EDB),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Botón Ver horarios
              InkWell(
                onTap: () {
                  // Navegar a pantalla de horarios
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _DoctorScheduleScreen(
                        especialidad: cardData['descripcion_especialidad'],
                        codEspecialidad: cardData['cod_especialidad'],
                        medico: cardData['nombre_prestador'],
                        codMedico: cardData['cod_prestador'],
                        sucursal: cardData['descripcion_sucursal'],
                        codSucursal: cardData['cod_sucursal'],
                        fecha: cardData['fecha'],
                        horariosDisponibles: List<String>.from(cardData['horarios']),
                        turnosCompletos: List<Map<String, dynamic>>.from(cardData['turnos']),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB47EDB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ver horarios disponibles',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDateSection(Map<String, dynamic> appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fecha
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFB47EDB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFFB47EDB), size: 20),
              const SizedBox(width: 8),
              Text(
                appointment['date'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB47EDB),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Cards de doctores para esta fecha
        Column(
          children: appointment['doctors'].map<Widget>((doctor) {
            return _buildDoctorCard(doctor, appointment['date']);
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildDoctorCard(Map<String, dynamic> doctor, String date) {
    return InkWell(
      onTap: () => _selectDoctor(doctor, date),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            // Avatar del doctor
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 30),
            ),
            const SizedBox(height: 8),
            // Nombre del doctor
            Text(
              doctor['name'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Especialidad
            Text(
              doctor['specialty'],
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Días de consulta
            Text(
              'Días de consultas:',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              doctor['consultationDays'],
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Botón agendar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFB47EDB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Agendar turno',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ignore: unused_element
  void _selectDoctor(Map<String, dynamic> doctor, String date) {
    // Método obsoleto - Ahora usamos _buildTurnoCard con navegación directa
  }

  // ignore: unused_element
  Future<void> _agendarConsulta() async {
    if (selectedSpecialty.isEmpty || selectedDoctor.isEmpty || selectedDate.isEmpty || selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Crear la consulta
      await _consultationService.createConsultation(
        specialty: selectedSpecialty,
        doctor: selectedDoctor,
        branch: selectedBranch,
        date: selectedDate,
        time: selectedTime,
      );

      setState(() {
        isLoading = false;
      });

      // Navegar a la pantalla de confirmación
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultaAgendadaScreen(
            specialty: selectedSpecialty,
            doctor: selectedDoctor,
            branch: selectedBranch,
            date: selectedDate,
            time: selectedTime,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agendar consulta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _DoctorScheduleScreen extends StatefulWidget {
  final String especialidad;
  final int codEspecialidad;
  final String medico;
  final int codMedico;
  final String sucursal;
  final int codSucursal;
  final String fecha;
  final List<String> horariosDisponibles;
  final List<Map<String, dynamic>> turnosCompletos; // Con id_det_aux

  const _DoctorScheduleScreen({
    required this.especialidad,
    required this.codEspecialidad,
    required this.medico,
    required this.codMedico,
    required this.sucursal,
    required this.codSucursal,
    required this.fecha,
    required this.horariosDisponibles,
    required this.turnosCompletos,
  });

  @override
  State<_DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<_DoctorScheduleScreen> {
  String selectedTime = '';
  int? selectedIdDetAux; // ID del turno seleccionado para reservar
  bool isLoading = false; // Para mostrar loading durante el agendamiento

  @override
  void initState() {
    super.initState();
    print('📅 [DEBUG] Pantalla de horarios cargada');
    print('📅 [DEBUG] Médico: ${widget.medico}');
    print('📅 [DEBUG] Especialidad: ${widget.especialidad}');
    print('📅 [DEBUG] Sucursal: ${widget.sucursal}');
    print('📅 [DEBUG] Fecha: ${widget.fecha}');
    print('📅 [DEBUG] Horarios disponibles: ${widget.horariosDisponibles.length}');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.getCurrentUser();
    final userEmail = currentUser?.email ?? 'Usuario';
    final username = userEmail.contains('@') 
        ? '@${userEmail.split('@')[0]}' 
        : userEmail;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB47EDB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Horarios disponibles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  username,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.person, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header morado extendido
          Container(
            width: double.infinity,
            height: 20,
            color: const Color(0xFFB47EDB),
          ),
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del doctor
                  _buildDoctorInfo(),
                  const SizedBox(height: 24),
                  // Horarios disponibles
                  _buildScheduleSection(),
                  const SizedBox(height: 24),
                  // Botones de acción
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
          // Logo de Certiva al final
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Image.asset(
                'assets/icons/logo_color.png',
                width: 151,
                height: 76,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Especialidad
          _buildFormField('Especialidad', widget.especialidad),
          const SizedBox(height: 16),
          // Médico
          _buildFormField('Médico', widget.medico),
          const SizedBox(height: 16),
          // Sucursal
          _buildFormField('Sucursal', widget.sucursal),
          const SizedBox(height: 16),
          // Fecha - Horario
          _buildFormField('Fecha - Horario', selectedTime.isEmpty ? 'Seleccionar horario' : '${widget.fecha} - $selectedTime hs'),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF09D5D6), width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.contains('Seleccionar') ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              if (label == 'Fecha - Horario')
                const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horarios disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB47EDB),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.horariosDisponibles.map((time) {
              final isSelected = selectedTime == time;
              
              return InkWell(
                onTap: () {
                  // Buscar el id_det_aux correspondiente a este horario
                  final turno = widget.turnosCompletos.firstWhere(
                    (t) => t['hora_disponible'] == time,
                    orElse: () => {},
                  );
                  
                  setState(() {
                    selectedTime = time;
                    selectedIdDetAux = turno['id_det_aux'];
                  });
                  
                  print('📅 [DEBUG] Horario seleccionado: $time');
                  print('📅 [DEBUG] ID del turno (id_det_aux): $selectedIdDetAux');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFB47EDB)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFB47EDB) : const Color(0xFF09D5D6),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFF09D5D6),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB47EDB),
              side: const BorderSide(color: Color(0xFFB47EDB)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Volver',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: selectedTime.isEmpty ? null : _confirmAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB47EDB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAppointment() async {
    print('📅 [DEBUG] Confirmando turno...');
    print('📅 [DEBUG] ID del turno (id_det_aux): $selectedIdDetAux');
    print('📅 [DEBUG] Médico: ${widget.medico}');
    print('📅 [DEBUG] Fecha: ${widget.fecha}');
    print('📅 [DEBUG] Hora: $selectedTime');
    
    if (selectedIdDetAux == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un horario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Buscar el turno seleccionado en los turnos completos
      final turnoSeleccionado = widget.turnosCompletos.firstWhere(
        (turno) => turno['id_det_aux'] == selectedIdDetAux,
        orElse: () => throw Exception('Turno no encontrado'),
      );
      
      // Formatear fecha para la API (DD/MM/YYYY HH:MM)
      final fechaFormateada = '${widget.fecha} ${selectedTime}';
      
      // Obtener el idCliente del usuario logueado
      final currentUser = UserService.getCurrentUser();
      if (currentUser?.idCliente == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener el ID del cliente. Por favor, inicie sesión nuevamente.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('📅 [DEBUG] Agendando turno...');
      print('📅 [DEBUG] Fecha formateada: $fechaFormateada');
      print('📅 [DEBUG] ID Det Aux: $selectedIdDetAux');
      print('📅 [DEBUG] ID Cliente: ${currentUser!.idCliente}');
      print('📅 [DEBUG] Profesional: ${widget.codMedico}');
      print('📅 [DEBUG] Box: ${turnoSeleccionado['cod_box']}');
      print('📅 [DEBUG] Sucursal: ${widget.codSucursal}');

      // Llamar a la API de agendamiento
      final resultado = await ConsultationService().agendarTurno(
        fechaReserva: fechaFormateada,
        idCliente: currentUser.idCliente!,
        idPersonaProf: widget.codMedico,
        idDetAux: selectedIdDetAux!,
        idBox: turnoSeleccionado['cod_box'],
        idSucursal: widget.codSucursal,
        observacion: 'Agendado desde la app móvil',
      );

      setState(() {
        isLoading = false;
      });

      if (resultado['success'] == true) {
        // Éxito - Navegar a pantalla de confirmación
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultaAgendadaScreen(
              specialty: widget.especialidad,
              doctor: widget.medico,
              branch: widget.sucursal,
              date: widget.fecha,
              time: selectedTime,
            ),
          ),
        );
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message'] ?? 'Error al agendar turno'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      print('📅 [ERROR] Error al confirmar agendamiento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agendar turno: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}