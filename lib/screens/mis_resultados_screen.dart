import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/lab_results_service.dart';
import '../services/estudios_api_service.dart';
import '../services/post_auth_service.dart';
import '../models/lab_result.dart';

class MisResultadosScreen extends StatefulWidget {
  const MisResultadosScreen({Key? key}) : super(key: key);

  @override
  State<MisResultadosScreen> createState() => _MisResultadosScreenState();
}

class _MisResultadosScreenState extends State<MisResultadosScreen> {
  final LabResultsService _labResultsService = LabResultsService();
  
  String selectedDate = '14/06/2025';
  String selectedStudy = 'Chequeo general completo';
  String selectedBranch = 'Certiva - Villa Morra';
  
  bool showDatePicker = false;
  bool showStudyDropdown = false;
  bool showBranchDropdown = false;
  bool isLoading = false;
  
  List<String> studies = [];
  List<String> branches = [];
  List<LabResult> results = [];
  List<Map<String, dynamic>> estudiosApi = [];
  int? idCliente;
  bool hasApiData = false;

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
      // Obtener usuario actual
      final currentUser = UserService.getCurrentUser();
      if (currentUser != null && currentUser.email.isNotEmpty) {
        print('🔬 [MisResultadosScreen] Cargando estudios para: ${currentUser.email}');
        
        // Verificar si el email está registrado y obtener id_cliente
        final authResult = await PostAuthService.verifyEmailAndGetClientId(currentUser.email);
        if (authResult['success'] == true) {
          idCliente = authResult['id_cliente'];
          print('🔬 [MisResultadosScreen] ID Cliente obtenido: $idCliente');
          
          // Cargar estudios desde la API
          final estudiosResult = await EstudiosApiService.getEstudiosCliente(idCliente!);
          if (estudiosResult['success'] == true) {
            estudiosApi = List<Map<String, dynamic>>.from(estudiosResult['estudios']);
            hasApiData = true;
            print('🔬 [MisResultadosScreen] Estudios cargados desde API: ${estudiosApi.length}');
          } else {
            print('🔬 [MisResultadosScreen] No se encontraron estudios en la API: ${estudiosResult['message']}');
          }
        } else {
          print('🔬 [MisResultadosScreen] Email no registrado en la API: ${authResult['message']}');
        }
      }

      // Cargar datos locales como respaldo
      final studiesData = await _labResultsService.getStudyTypes();
      final branchesData = await _labResultsService.getBranches();
      final resultsData = await _labResultsService.getAllResults();

      setState(() {
        studies = studiesData;
        branches = branchesData;
        results = resultsData;
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
          'Mis resultados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Botón de actualizar
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshFromApi,
            tooltip: 'Actualizar desde API',
          ),
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
            child: isLoading && results.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB47EDB)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando resultados...',
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
                        // Sección de resultados
                        _buildResultsSection(),
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
          // Fecha
          _buildFilterField(
            label: 'Fecha',
            value: selectedDate,
            icon: Icons.calendar_today,
            onTap: () {
              setState(() {
                showDatePicker = !showDatePicker;
                showStudyDropdown = false;
                showBranchDropdown = false;
              });
            },
          ),
          if (showDatePicker) _buildDatePicker(),
          
          const SizedBox(height: 16),
          
          // Estudio realizado
          _buildFilterField(
            label: 'Estudio realizado',
            value: selectedStudy,
            icon: Icons.keyboard_arrow_down,
            onTap: () {
              setState(() {
                showStudyDropdown = !showStudyDropdown;
                showDatePicker = false;
                showBranchDropdown = false;
              });
            },
          ),
          if (showStudyDropdown) _buildDropdown(studies, selectedStudy, (value) {
            setState(() {
              selectedStudy = value;
              showStudyDropdown = false;
            });
          }),
          
          const SizedBox(height: 16),
          
          // Sucursal
          _buildFilterField(
            label: 'Sucursal',
            value: selectedBranch,
            icon: Icons.keyboard_arrow_down,
            onTap: () {
              setState(() {
                showBranchDropdown = !showBranchDropdown;
                showDatePicker = false;
                showStudyDropdown = false;
              });
            },
          ),
          if (showBranchDropdown) _buildDropdown(branches, selectedBranch, (value) {
            setState(() {
              selectedBranch = value;
              showBranchDropdown = false;
            });
          }),
          
          const SizedBox(height: 16),
          
          // Botones de consulta - COMENTADOS
          // Row(
          //   children: [
          //     // Botón consultar local
          //     Expanded(
          //       child: ElevatedButton(
          //         onPressed: isLoading ? null : _consultarResultados,
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: const Color(0xFFB47EDB),
          //           foregroundColor: Colors.white,
          //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //         ),
          //         child: isLoading
          //             ? const SizedBox(
          //                 width: 20,
          //                 height: 20,
          //                 child: CircularProgressIndicator(
          //                   strokeWidth: 2,
          //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //                 ),
          //               )
          //             : const Text(
          //                 'Consultar Local',
          //                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          //               ),
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     // Botón consultar API
          //     Expanded(
          //       child: ElevatedButton(
          //         onPressed: isLoading ? null : _consultarDesdeApi,
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: const Color(0xFF09D5D6),
          //           foregroundColor: Colors.white,
          //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //         ),
          //         child: isLoading
          //             ? const SizedBox(
          //                 width: 20,
          //                 height: 20,
          //                 child: CircularProgressIndicator(
          //                   strokeWidth: 2,
          //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //                 ),
          //               )
          //             : const Text(
          //                 'Consultar API',
          //                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          //               ),
          //       ),
          //     ),
          //   ],
          // ),
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
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF09D5D6)),
              const SizedBox(width: 8),
              const Text(
                'Julio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ],
          ),
          const Divider(color: Color(0xFF09D5D6)),
          const Text(
            'Viernes, 28 de julio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // Calendario simplificado
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          // Botones de acción
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
                    selectedDate = '28/07/2025';
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
    final selectedDay = 28;
    
    return Column(
      children: [
        // Días de la semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((day) => Text(
            day,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          )).toList(),
        ),
        const SizedBox(height: 8),
        // Grilla de fechas
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: 31,
          itemBuilder: (context, index) {
            final day = index + 1;
            final isSelected = day == selectedDay;
            final isNearSelected = (day >= selectedDay - 1 && day <= selectedDay + 1);
            
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF09D5D6) 
                    : isNearSelected 
                        ? const Color(0xFF09D5D6).withOpacity(0.3)
                        : Colors.transparent,
                shape: BoxShape.circle,
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

  Widget _buildResultsSection() {
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
              child: Row(
                children: [
                  const Text(
                    'Detalles resultados',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Indicador de fuente de datos
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasApiData 
                          ? const Color(0xFF09D5D6).withOpacity(0.2)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasApiData ? Icons.cloud_done : Icons.storage,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasApiData ? 'API' : 'Local',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tabla de resultados
            Expanded(
              child: hasApiData && estudiosApi.isNotEmpty
                  ? _buildApiResultsList()
                  : results.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assessment_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No se encontraron resultados',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Intenta con otros filtros',
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
                          DataColumn(label: Text('Ítems')),
                          DataColumn(label: Text('Fecha')),
                          DataColumn(label: Text('Sucursal')),
                          DataColumn(label: Text('PDF')),
                        ],
                        rows: results.map((result) => _buildResultRow(result)).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildResultRow(LabResult result) {
    return DataRow(
      cells: [
        DataCell(Text(result.item)),
        DataCell(Text(result.date)),
        DataCell(Text(result.branch)),
        DataCell(
          ElevatedButton.icon(
            onPressed: () => _downloadPdf(result),
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

  Future<void> _consultarResultados() async {
    setState(() {
      isLoading = true;
    });

    try {
      final filteredResults = await _labResultsService.filterResults(
        date: selectedDate,
        studyType: selectedStudy,
        branch: selectedBranch,
      );

      setState(() {
        results = filteredResults;
        hasApiData = false; // Mostrar datos locales
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se encontraron ${results.length} resultados locales'),
          backgroundColor: const Color(0xFFB47EDB),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al consultar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _consultarDesdeApi() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtener usuario actual
      final currentUser = UserService.getCurrentUser();
      if (currentUser == null || currentUser.email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró usuario logueado'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('🔬 [MisResultadosScreen] Consultando API para: ${currentUser.email}');
      
      // Verificar si el email está registrado y obtener id_cliente
      final authResult = await PostAuthService.verifyEmailAndGetClientId(currentUser.email);
      if (authResult['success'] == true) {
        idCliente = authResult['id_cliente'];
        print('🔬 [MisResultadosScreen] ID Cliente obtenido: $idCliente');
        
        // Cargar estudios desde la API
        final estudiosResult = await EstudiosApiService.getEstudiosCliente(idCliente!);
        if (estudiosResult['success'] == true) {
          estudiosApi = List<Map<String, dynamic>>.from(estudiosResult['estudios']);
          hasApiData = true;
          print('🔬 [MisResultadosScreen] Estudios cargados desde API: ${estudiosApi.length}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Se encontraron ${estudiosApi.length} estudios en la API'),
              backgroundColor: const Color(0xFF09D5D6),
            ),
          );
        } else {
          print('🔬 [MisResultadosScreen] No se encontraron estudios en la API: ${estudiosResult['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontraron estudios: ${estudiosResult['message']}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        print('🔬 [MisResultadosScreen] Email no registrado en la API: ${authResult['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email no registrado: ${authResult['message']}'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('🚨 [MisResultadosScreen] Error al consultar API: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al consultar API: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshFromApi() async {
    await _consultarDesdeApi();
  }

  Future<void> _downloadPdf(LabResult result) async {
    try {
      final success = await _labResultsService.downloadPdf(result.id);
      if (success) {
        await _labResultsService.markAsDownloaded(result.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.item} descargado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildApiResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: estudiosApi.length,
      itemBuilder: (context, index) {
        final estudio = estudiosApi[index];
        return _buildApiResultCard(estudio);
      },
    );
  }

  Widget _buildApiResultCard(Map<String, dynamic> estudio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
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
          // Header del estudio
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF09D5D6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ID: ${estudio['cod_solicitud']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB47EDB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  estudio['fecha_solicitud'] ?? 'N/A',
                  style: const TextStyle(
                    color: Color(0xFFB47EDB),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Nombre del análisis
          Text(
            estudio['analisis'] ?? 'Análisis no especificado',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // Sucursal
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  estudio['nombre_sucursal'] ?? 'Sucursal no especificada',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Código de firma
          Row(
            children: [
              const Icon(Icons.fingerprint, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Código de firma: ${estudio['cod_firma'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Botón de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewEstudioDetails(estudio),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver detalles'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF09D5D6),
                    side: const BorderSide(color: Color(0xFF09D5D6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadEstudio(estudio),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Descargar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB47EDB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _viewEstudioDetails(Map<String, dynamic> estudio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(estudio['analisis'] ?? 'Detalles del estudio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Análisis', estudio['analisis'] ?? 'N/A'),
            _buildDetailRow('Fecha de solicitud', estudio['fecha_solicitud'] ?? 'N/A'),
            _buildDetailRow('Código de solicitud', estudio['cod_solicitud']?.toString() ?? 'N/A'),
            _buildDetailRow('Sucursal', estudio['nombre_sucursal'] ?? 'N/A'),
            _buildDetailRow('Código de sucursal', estudio['cod_sucursal']?.toString() ?? 'N/A'),
            _buildDetailRow('Código de firma', estudio['cod_firma']?.toString() ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _downloadEstudio(Map<String, dynamic> estudio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando ${estudio['analisis']}...'),
        backgroundColor: const Color(0xFF09D5D6),
      ),
    );
    // TODO: Implementar descarga real
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
} 