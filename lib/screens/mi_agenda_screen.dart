import 'package:flutter/material.dart';
import '../services/consultation_service.dart';
import '../services/user_service.dart';
import '../models/consultation.dart';

class MiAgendaScreen extends StatefulWidget {
  const MiAgendaScreen({Key? key}) : super(key: key);

  @override
  State<MiAgendaScreen> createState() => _MiAgendaScreenState();
}

class _MiAgendaScreenState extends State<MiAgendaScreen> {
  final ConsultationService _consultationService = ConsultationService();
  
  // Variables para el calendario dinámico
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  
  String selectedDate = '';
  String selectedBranch = '';
  int selectedBranchCode = 0;
  String selectedAgenda = 'Próximas consultas - general';
  
  bool showDatePicker = false;
  bool showBranchDropdown = false;
  bool showAgendaDropdown = false;
  bool isLoading = false;
  
  List<Map<String, dynamic>> branches = [];
  List<String> agendaOptions = [
    'Próximas consultas - general',
    'Consultas anteriores - general',
    'Todas las consultas - general',
  ];
  List<Consultation> consultations = [];

  @override
  void initState() {
    super.initState();
    selectedDate = _formatDate(_selectedDate);
    _loadInitialData();
  }

  // Formatear fecha a español
  String _formatDate(DateTime date) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    const weekdays = [
      'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    
    return '${weekday[0].toUpperCase()}${weekday.substring(1)}, $day de $month';
  }

  // Obtener nombre del mes
  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  // Obtener días en el mes
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // Obtener el primer día de la semana del mes (0 = Domingo)
  int _getFirstDayOfWeek(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  // Navegar al mes anterior
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  // Navegar al mes siguiente
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Cargar sucursales y consultas en paralelo
      final results = await Future.wait([
        _consultationService.getBranches(),
        _consultationService.getAllConsultations(),
      ]);

      final branchesData = results[0] as List<Map<String, dynamic>>;
      final consultationsData = results[1] as List<Consultation>;

      print('🏥 [DEBUG] Sucursales cargadas: ${branchesData.length}');
      print('🏥 [DEBUG] Sucursales: $branchesData');
      print('📅 [DEBUG] Consultas cargadas: ${consultationsData.length}');

      setState(() {
        branches = branchesData;
        consultations = consultationsData;
        isLoading = false;
      });

      // Mostrar mensaje informativo
      if (mounted && consultationsData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay consultas agendadas'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('🏥 [ERROR] Error al cargar datos: $e');
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          'Mi agenda',
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
            child: isLoading && branches.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB47EDB)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando agenda...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de filtros
                        _buildFilterSection(),
                        const SizedBox(height: 24),
                        // Sección de detalles
                        _buildDetailsSection(),
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
          // Consultas agendadas
          _buildFilterField(
            label: 'Consultas agendadas',
            value: selectedDate,
            icon: Icons.calendar_today,
            onTap: () {
              setState(() {
                showDatePicker = !showDatePicker;
                showBranchDropdown = false;
                showAgendaDropdown = false;
              });
            },
          ),
          if (showDatePicker) _buildDatePicker(),
          
          const SizedBox(height: 16),
          
          // Sucursal
          _buildFilterField(
            label: 'Sucursal',
            value: selectedBranch.isEmpty ? 'Seleccionar sucursal' : selectedBranch,
            icon: Icons.keyboard_arrow_down,
            onTap: () {
              setState(() {
                showBranchDropdown = !showBranchDropdown;
                showDatePicker = false;
                showAgendaDropdown = false;
              });
            },
          ),
          if (showBranchDropdown) _buildBranchDropdown(),
          
          const SizedBox(height: 16),
          
          // Agenda
          _buildFilterField(
            label: 'Agenda',
            value: selectedAgenda,
            icon: Icons.keyboard_arrow_down,
            onTap: () {
              setState(() {
                showAgendaDropdown = !showAgendaDropdown;
                showDatePicker = false;
                showBranchDropdown = false;
              });
            },
          ),
          if (showAgendaDropdown) _buildDropdown(agendaOptions, selectedAgenda, (value) {
            setState(() {
              selectedAgenda = value;
              showAgendaDropdown = false;
            });
          }),
          
          const SizedBox(height: 16),
          
          // Botón ver
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: isLoading ? null : _verConsultas,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB47EDB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Ver',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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

  Widget _buildDatePicker() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header con mes/año y navegación
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF09D5D6)),
              const SizedBox(width: 8),
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const Divider(color: Color(0xFF09D5D6)),
          Text(
            _formatDate(_selectedDate),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    showDatePicker = false;
                  });
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedDate = _formatDate(_selectedDate);
                    showDatePicker = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB47EDB),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Seleccionar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    const days = ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'];
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstDayOfWeek = _getFirstDayOfWeek(_currentMonth);
    final totalCells = firstDayOfWeek + daysInMonth;
    
    return Column(
      children: [
        // Headers de días de la semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((day) => Text(
            day,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          )).toList(),
        ),
        const SizedBox(height: 8),
        // Grid de días
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            // Celdas vacías antes del primer día del mes
            if (index < firstDayOfWeek) {
              return const SizedBox.shrink();
            }
            
            final day = index - firstDayOfWeek + 1;
            final currentDate = DateTime(_currentMonth.year, _currentMonth.month, day);
            final isSelected = _selectedDate.year == currentDate.year &&
                              _selectedDate.month == currentDate.month &&
                              _selectedDate.day == currentDate.day;
            final isToday = DateTime.now().year == currentDate.year &&
                           DateTime.now().month == currentDate.month &&
                           DateTime.now().day == currentDate.day;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = currentDate;
                });
              },
              child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF09D5D6) 
                      : isToday 
                        ? const Color(0xFF09D5D6).withOpacity(0.3)
                        : Colors.transparent,
                shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: const Color(0xFF09D5D6), width: 2)
                      : null,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

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

  Widget _buildDetailsSection() {
    return Expanded(
      child: Container(
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
          children: [
            // Header de la sección
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFB47EDB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Detalles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Tabla de consultas
            Expanded(
              child: consultations.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay consultas agendadas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Agenda una consulta para verla aquí',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                          color: Color(0xFFB47EDB),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        dataTextStyle: const TextStyle(fontSize: 14),
                        columns: const [
                          DataColumn(label: Text('Médico')),
                          DataColumn(label: Text('Especialidad')),
                          DataColumn(label: Text('Fecha')),
                          DataColumn(label: Text('Hora')),
                          DataColumn(label: Text('Sucursal')),
                          DataColumn(label: Text('Factura')),
                        ],
                        rows: consultations.map((consultation) => _buildConsultationRow(consultation)).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildConsultationRow(Consultation consultation) {
    return DataRow(
      cells: [
        DataCell(Text(consultation.doctor)),
        DataCell(Text(consultation.specialty)),
        DataCell(Text(consultation.date)),
        DataCell(Text(consultation.time)),
        DataCell(Text(consultation.branch)),
        DataCell(
          ElevatedButton.icon(
            onPressed: () => _downloadInvoice(consultation),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Descargar', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB47EDB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 32),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _verConsultas() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtener todas las consultas de la API
      final allConsultations = await _consultationService.getAllConsultations();
      
      // Aplicar filtros
      List<Consultation> filteredConsultations = allConsultations;

      // Filtrar por sucursal si se seleccionó una
      if (selectedBranch.isNotEmpty) {
        filteredConsultations = filteredConsultations
            .where((c) => c.branch.toLowerCase().contains(selectedBranch.toLowerCase()))
            .toList();
      }

      // Filtrar por tipo de agenda
      if (selectedAgenda.contains('Próximas')) {
        // Solo consultas agendadas (RESERVADO)
        filteredConsultations = filteredConsultations
            .where((c) => c.status == 'scheduled')
            .toList();
      } else if (selectedAgenda.contains('anteriores')) {
        // Solo consultas completadas (CERRADO)
        filteredConsultations = filteredConsultations
            .where((c) => c.status == 'completed')
            .toList();
      }
      // Si es "Todas las consultas" no filtramos por estado

      setState(() {
        consultations = filteredConsultations;
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se encontraron ${consultations.length} consultas'),
            backgroundColor: const Color(0xFFB47EDB),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al filtrar consultas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadInvoice(Consultation consultation) async {
    try {
      // Simular descarga de factura
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Factura de ${consultation.doctor} descargada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar factura: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 