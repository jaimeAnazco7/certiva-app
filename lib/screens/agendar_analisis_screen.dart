import 'package:flutter/material.dart';
import '../services/lab_analysis_service.dart';
import '../services/user_service.dart';
import 'analisis_agendado_screen.dart';

class AgendarAnalisisScreen extends StatefulWidget {
  const AgendarAnalisisScreen({Key? key}) : super(key: key);

  @override
  State<AgendarAnalisisScreen> createState() => _AgendarAnalisisScreenState();
}

class _AgendarAnalisisScreenState extends State<AgendarAnalisisScreen> {
  final LabAnalysisService _labAnalysisService = LabAnalysisService();
  
  // Variables para el calendario dinámico
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  
  List<String> selectedExams = [];
  String selectedBranch = 'Certiva - Villa Morra';
  String selectedDate = '';
  String selectedTime = '13:00';
  
  bool showExamsDropdown = false;
  bool showBranchDropdown = false;
  bool showDatePicker = false;
  bool showTimePicker = false;
  bool isLoading = false;
  
  List<String> availableExams = [];
  List<String> branches = [];
  List<String> availableTimes = [];
  List<String> unavailableTimes = ['9:00', '12:00', '16:00', '19:00'];

  @override
  void initState() {
    super.initState();
    selectedDate = _formatDateShort(_selectedDate);
    _loadInitialData();
  }

  // Formatear fecha a español formato corto (DD/MM/YYYY)
  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Formatear fecha a español formato largo
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
      final examsData = await _labAnalysisService.getAvailableExams();
      final branchesData = await _labAnalysisService.getBranches();
      final timesData = await _labAnalysisService.getAvailableTimes();

      setState(() {
        availableExams = examsData;
        branches = branchesData;
        availableTimes = timesData;
        isLoading = false;
      });
    } catch (e) {
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
          'Agendar análisis',
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
            child: isLoading && availableExams.isEmpty
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
                        // Sección de exámenes
                        _buildExamsSection(),
                        
                        const SizedBox(height: 16),
                        
                        // Sección de sucursal
                        _buildBranchSection(),
                        
                        const SizedBox(height: 16),
                        
                        // Sección de fecha y horario
                        _buildDateTimeSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Botón agendar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedExams.isEmpty || isLoading ? null : _agendarAnalisis,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB47EDB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    'Agendar',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
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

  Widget _buildExamsSection() {
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
          Row(
            children: [
              const Text(
                'Exámenes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB47EDB),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    showExamsDropdown = !showExamsDropdown;
                    showBranchDropdown = false;
                    showDatePicker = false;
                    showTimePicker = false;
                  });
                },
                icon: Icon(
                  showExamsDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFFB47EDB),
                ),
              ),
            ],
          ),
          
          if (selectedExams.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...selectedExams.map((exam) => _buildSelectedExamItem(exam)),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF09D5D6)),
          ],
          
          if (showExamsDropdown) _buildExamsDropdown(),
        ],
      ),
    );
  }

  Widget _buildSelectedExamItem(String exam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFB47EDB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              exam,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB47EDB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedExams.remove(exam);
              });
            },
            icon: const Icon(
              Icons.close,
              color: Color(0xFFB47EDB),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildExamsDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB47EDB).withOpacity(0.3)),
      ),
      child: Column(
        children: availableExams.map((exam) => InkWell(
          onTap: () {
            setState(() {
              if (selectedExams.contains(exam)) {
                selectedExams.remove(exam);
              } else {
                selectedExams.add(exam);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selectedExams.contains(exam) 
                  ? const Color(0xFFB47EDB).withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exam,
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedExams.contains(exam) 
                          ? const Color(0xFFB47EDB)
                          : Colors.grey,
                    ),
                  ),
                ),
                if (selectedExams.contains(exam))
                  const Icon(Icons.check, color: Color(0xFFB47EDB), size: 16),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBranchSection() {
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
            'Sucursal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                showBranchDropdown = !showBranchDropdown;
                showExamsDropdown = false;
                showDatePicker = false;
                showTimePicker = false;
              });
            },
            child: Container(
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
                      selectedBranch,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          
          if (showBranchDropdown) _buildDropdown(branches, selectedBranch, (value) {
            setState(() {
              selectedBranch = value;
              showBranchDropdown = false;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
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
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF09D5D6), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Fecha - Horario',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                showDatePicker = !showDatePicker;
                showExamsDropdown = false;
                showBranchDropdown = false;
                showTimePicker = false;
              });
            },
            child: Container(
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
                      '$selectedDate - $selectedTime hrs',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          
          if (showDatePicker) _buildDatePicker(),
          
          const SizedBox(height: 16),
          
          // Horarios disponibles
          const Text(
            'Horarios disponibles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB47EDB),
            ),
          ),
          const SizedBox(height: 16),
          _buildAvailableTimesGrid(),
          const SizedBox(height: 8),
          const Text(
            '*Las casillas marcadas ya no se encuentran disponibles',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
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
                    selectedDate = _formatDateShort(_selectedDate);
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

  Widget _buildAvailableTimesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTimes.map((time) {
        final isUnavailable = unavailableTimes.contains(time);
        final isSelected = time == selectedTime;
        
        return InkWell(
          onTap: isUnavailable ? null : () {
            setState(() {
              selectedTime = time;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isUnavailable 
                  ? const Color(0xFF09D5D6)
                  : isSelected
                      ? const Color(0xFFB47EDB)
                      : Colors.transparent,
              border: Border.all(
                color: const Color(0xFF09D5D6),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isUnavailable || isSelected ? Colors.white : const Color(0xFF09D5D6),
              ),
            ),
          ),
        );
      }).toList(),
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

  Future<void> _agendarAnalisis() async {
    if (selectedExams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar al menos un examen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Verificar disponibilidad del horario
      final isAvailable = await _labAnalysisService.isTimeAvailable(selectedDate, selectedTime);
      
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El horario seleccionado no está disponible'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Crear el análisis
      await _labAnalysisService.createAnalysis(
        exams: selectedExams,
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
          builder: (context) => AnalisisAgendadoScreen(
            exams: selectedExams,
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
          content: Text('Error al agendar análisis: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 