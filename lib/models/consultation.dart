import 'package:flutter/material.dart';

class Consultation {
  final String id;
  final String specialty;
  final String doctor;
  final String branch;
  final String date;
  final String time;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;

  Consultation({
    required this.id,
    required this.specialty,
    required this.doctor,
    required this.branch,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] ?? '',
      specialty: json['specialty'] ?? '',
      doctor: json['doctor'] ?? '',
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
      'specialty': specialty,
      'doctor': doctor,
      'branch': branch,
      'date': date,
      'time': time,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Consultation copyWith({
    String? id,
    String? specialty,
    String? doctor,
    String? branch,
    String? date,
    String? time,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      specialty: specialty ?? this.specialty,
      doctor: doctor ?? this.doctor,
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
        return 'Agendada';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
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
} 