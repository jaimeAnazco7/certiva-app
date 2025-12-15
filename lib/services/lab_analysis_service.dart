import '../models/lab_analysis.dart';

class LabAnalysisService {
  static final LabAnalysisService _instance = LabAnalysisService._internal();
  factory LabAnalysisService() => _instance;
  LabAnalysisService._internal();

  // Datos de ejemplo para simular la API
  final List<LabAnalysis> _mockAnalyses = [
    LabAnalysis(
      id: '1',
      exams: ['VADI - Antígeno DU', 'HE4 - Antígeno HE-4 Sangre'],
      branch: 'Certiva - Villa Morra',
      date: '28/07/2025',
      time: '13:00',
      status: 'scheduled',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LabAnalysis(
      id: '2',
      exams: ['AIC - Glucohemoglobina', 'GPD - Glucosa Pre y Post desayuno'],
      branch: 'Certiva - Villa Morra',
      date: '25/07/2025',
      time: '10:00',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Obtener todos los análisis del usuario
  Future<List<LabAnalysis>> getAllAnalyses() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockAnalyses;
  }

  // Obtener análisis por estado
  Future<List<LabAnalysis>> getAnalysesByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockAnalyses.where((analysis) => analysis.status == status).toList();
  }

  // Crear un nuevo análisis
  Future<LabAnalysis> createAnalysis({
    required List<String> exams,
    required String branch,
    required String date,
    required String time,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final newAnalysis = LabAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exams: exams,
      branch: branch,
      date: date,
      time: time,
      status: 'scheduled',
      createdAt: DateTime.now(),
    );

    _mockAnalyses.add(newAnalysis);
    return newAnalysis;
  }

  // Cancelar un análisis
  Future<bool> cancelAnalysis(String analysisId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _mockAnalyses.indexWhere((a) => a.id == analysisId);
    if (index != -1) {
      _mockAnalyses[index] = _mockAnalyses[index].copyWith(
        status: 'cancelled',
        notes: reason,
      );
      return true;
    }
    return false;
  }

  // Marcar análisis como completado
  Future<bool> completeAnalysis(String analysisId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _mockAnalyses.indexWhere((a) => a.id == analysisId);
    if (index != -1) {
      _mockAnalyses[index] = _mockAnalyses[index].copyWith(
        status: 'completed',
      );
      return true;
    }
    return false;
  }

  // Obtener exámenes disponibles
  Future<List<String>> getAvailableExams() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'VADI - Antígeno DU',
      'HE4 - Antígeno HE-4 Sangre',
      'AIC - Glucohemoglobina',
      'GPD - Glucosa Pre y Post desayuno',
      'T3 - Triiodotironina total',
      'T4 - Tiroxina total',
      'TSH - Hormona estimulante de la tiroides',
      'Hemograma completo',
      'Perfil lipídico',
      'Perfil hepático',
      'Perfil renal',
      'Análisis de orina',
      'Análisis de heces',
      'Prueba de embarazo',
      'VIH - Anticuerpos',
      'Hepatitis B - Antígeno de superficie',
      'Hepatitis C - Anticuerpos',
    ];
  }

  // Obtener sucursales disponibles
  Future<List<String>> getBranches() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'Certiva - Villa Morra',
      'Certiva - Luque',
      'Óptica Valemar - Asunción',
      'Luque - Centro Médico San Juan',
      'Asunción - Centro',
      'San Lorenzo - Sucursal Sur',
      'Encarnación - Sucursal Sur',
      'Ciudad del Este - Sucursal Este',
    ];
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
    final unavailableTimes = ['9:00', '12:00', '16:00', '19:00'];
    return !unavailableTimes.contains(time);
  }

  // Obtener precio de exámenes
  Future<Map<String, double>> getExamPrices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return {
      'VADI - Antígeno DU': 150000.0,
      'HE4 - Antígeno HE-4 Sangre': 180000.0,
      'AIC - Glucohemoglobina': 120000.0,
      'GPD - Glucosa Pre y Post desayuno': 80000.0,
      'T3 - Triiodotironina total': 100000.0,
      'T4 - Tiroxina total': 100000.0,
      'TSH - Hormona estimulante de la tiroides': 120000.0,
      'Hemograma completo': 60000.0,
      'Perfil lipídico': 80000.0,
      'Perfil hepático': 100000.0,
      'Perfil renal': 90000.0,
      'Análisis de orina': 40000.0,
      'Análisis de heces': 50000.0,
      'Prueba de embarazo': 30000.0,
      'VIH - Anticuerpos': 80000.0,
      'Hepatitis B - Antígeno de superficie': 120000.0,
      'Hepatitis C - Anticuerpos': 120000.0,
    };
  }

  // Calcular precio total de exámenes
  Future<double> calculateTotalPrice(List<String> exams) async {
    final prices = await getExamPrices();
    double total = 0.0;
    
    for (final exam in exams) {
      total += prices[exam] ?? 0.0;
    }
    
    return total;
  }
} 