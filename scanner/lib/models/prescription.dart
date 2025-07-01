class Prescription {
  final String id;
  final DateTime date;
  final String patientName;
  final String doctorName;
  final List<Medication> medications;
  final String? notes;
  final String? imagePath;

  Prescription({
    required this.id,
    required this.date,
    required this.patientName,
    required this.doctorName,
    required this.medications,
    this.notes,
    this.imagePath,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      date: DateTime.parse(json['date']),
      patientName: json['patientName'],
      doctorName: json['doctorName'],
      medications:
          (json['medications'] as List)
              .map((item) => Medication.fromJson(item))
              .toList(),
      notes: json['notes'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'patientName': patientName,
      'doctorName': doctorName,
      'medications': medications.map((med) => med.toJson()).toList(),
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  Prescription copyWith({
    String? id,
    DateTime? date,
    String? patientName,
    String? doctorName,
    List<Medication>? medications,
    String? notes,
    String? imagePath,
  }) {
    return Prescription(
      id: id ?? this.id,
      date: date ?? this.date,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }
}
