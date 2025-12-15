class LabResult {
  final String id;
  final String item;
  final String date;
  final String branch;
  final String studyType;
  final String pdfUrl;
  final bool isDownloaded;

  LabResult({
    required this.id,
    required this.item,
    required this.date,
    required this.branch,
    required this.studyType,
    required this.pdfUrl,
    this.isDownloaded = false,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'] ?? '',
      item: json['item'] ?? '',
      date: json['date'] ?? '',
      branch: json['branch'] ?? '',
      studyType: json['studyType'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      isDownloaded: json['isDownloaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'date': date,
      'branch': branch,
      'studyType': studyType,
      'pdfUrl': pdfUrl,
      'isDownloaded': isDownloaded,
    };
  }

  LabResult copyWith({
    String? id,
    String? item,
    String? date,
    String? branch,
    String? studyType,
    String? pdfUrl,
    bool? isDownloaded,
  }) {
    return LabResult(
      id: id ?? this.id,
      item: item ?? this.item,
      date: date ?? this.date,
      branch: branch ?? this.branch,
      studyType: studyType ?? this.studyType,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
} 