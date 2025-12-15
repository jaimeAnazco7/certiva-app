import '../models/lab_result.dart';

class LabResultsService {
  static final LabResultsService _instance = LabResultsService._internal();
  factory LabResultsService() => _instance;
  LabResultsService._internal();

  // Datos de ejemplo para simular la API
  final List<LabResult> _mockResults = [
    LabResult(
      id: '1',
      item: 'Resultados análisis de sangre',
      date: '14/06/2025',
      branch: 'Villa Morra',
      studyType: 'Chequeo general completo',
      pdfUrl: 'https://certiva.com/results/1.pdf',
    ),
    LabResult(
      id: '2',
      item: 'Resultados orina simple',
      date: '14/06/2025',
      branch: 'Villa Morra',
      studyType: 'Chequeo general completo',
      pdfUrl: 'https://certiva.com/results/2.pdf',
    ),
    LabResult(
      id: '3',
      item: 'Perfil lipídico completo',
      date: '10/06/2025',
      branch: 'Villa Morra',
      studyType: 'Perfil lipídico',
      pdfUrl: 'https://certiva.com/results/3.pdf',
    ),
    LabResult(
      id: '4',
      item: 'Análisis de glucosa',
      date: '05/06/2025',
      branch: 'Villa Morra',
      studyType: 'Prueba de glucosa',
      pdfUrl: 'https://certiva.com/results/4.pdf',
    ),
    LabResult(
      id: '5',
      item: 'Hemograma completo',
      date: '01/06/2025',
      branch: 'Luque - Centro Médico San Juan',
      studyType: 'Análisis de sangre',
      pdfUrl: 'https://certiva.com/results/5.pdf',
    ),
  ];

  // Obtener todos los resultados
  Future<List<LabResult>> getAllResults() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockResults;
  }

  // Filtrar resultados por criterios
  Future<List<LabResult>> filterResults({
    String? date,
    String? studyType,
    String? branch,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
    
    List<LabResult> filteredResults = _mockResults;

    if (date != null && date.isNotEmpty) {
      filteredResults = filteredResults.where((result) => result.date == date).toList();
    }

    if (studyType != null && studyType.isNotEmpty) {
      filteredResults = filteredResults.where((result) => result.studyType == studyType).toList();
    }

    if (branch != null && branch.isNotEmpty) {
      filteredResults = filteredResults.where((result) => result.branch == branch).toList();
    }

    return filteredResults;
  }

  // Obtener tipos de estudios disponibles
  Future<List<String>> getStudyTypes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'Chequeo general completo',
      'Perfil lipídico',
      'Análisis de sangre',
      'Análisis de orina',
      'Prueba de glucosa',
      'Hemograma completo',
      'Perfil hepático',
      'Perfil renal',
    ];
  }

  // Obtener sucursales disponibles
  Future<List<String>> getBranches() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'Certiva - Villa Morra',
      'Luque - Centro Médico San Juan',
      'Asunción - Centro',
      'San Lorenzo - Sucursal Sur',
      'Encarnación - Sucursal Sur',
      'Ciudad del Este - Sucursal Este',
    ];
  }

  // Descargar PDF
  Future<bool> downloadPdf(String resultId) async {
    // Simular descarga
    await Future.delayed(const Duration(seconds: 2));
    
    // En una implementación real, aquí se descargaría el archivo
    // y se guardaría en el almacenamiento local del dispositivo
    
    return true;
  }

  // Marcar resultado como descargado
  Future<void> markAsDownloaded(String resultId) async {
    // En una implementación real, esto actualizaría el estado en la base de datos
    await Future.delayed(const Duration(milliseconds: 100));
  }
} 