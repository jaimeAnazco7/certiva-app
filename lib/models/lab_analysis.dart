import 'package:flutter/material.dart';

class LabAnalysis {
  final String id;
  final List<String> exams;
  final String branch;
  final String date;
  final String time;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;

  LabAnalysis({
    required this.id,
    required this.exams,
    required this.branch,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory LabAnalysis.fromJson(Map<String, dynamic> json) {
    return LabAnalysis(
      id: json['id'] ?? '',
      exams: List<String>.from(json['exams'] ?? []),
      branch: json['branch'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'scheduled',
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exams': exams,
      'branch': branch,
      'date': date,
      'time': time,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LabAnalysis copyWith({
    String? id,
    List<String>? exams,
    String? branch,
    String? date,
    String? time,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return LabAnalysis(
      id: id ?? this.id,
      exams: exams ?? this.exams,
      branch: branch ?? this.branch,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusText {
    switch (status) {
      case 'scheduled':
        return 'Agendado';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'scheduled':
        return const Color(0xFF09D5D6);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get examsText {
    return exams.join(', ');
  }

  int get examsCount {
    return exams.length;
  }
} 