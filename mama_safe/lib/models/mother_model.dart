import 'dart:convert';

/// Mother model - Represents a registered pregnant mother
class MotherModel {
  final String id;
  final String fullName;
  final int age;
  final String phoneNumber;
  final String address;
  final String emergencyContact;
  final String assignedChwId;
  final String assignedChwName;
  final String riskLevel; // "Not Predicted", "Low", "Mid", "High"
  final String status; // "active", "referred", "completed"
  final bool hasScheduledAppointment;
  final DateTime createdAt;
  final DateTime? nextVisitDate;
  final DateTime? lastVisitDate;
  final DateTime? dueDate;

  // Prediction data
  final int? systolicBP;
  final int? diastolicBP;
  final double? bloodSugar;
  final double? bodyTemp;
  final int? heartRate;

  // Medical history
  final String? medication;
  final String? allergies;
  final String? diseases;

  MotherModel({
    required this.id,
    required this.fullName,
    required this.age,
    required this.phoneNumber,
    required this.address,
    required this.emergencyContact,
    required this.assignedChwId,
    required this.assignedChwName,
    this.riskLevel = "Not Predicted",
    this.status = "active",
    this.hasScheduledAppointment = false,
    DateTime? createdAt,
    this.nextVisitDate,
    this.lastVisitDate,
    this.dueDate,
    this.systolicBP,
    this.diastolicBP,
    this.bloodSugar,
    this.bodyTemp,
    this.heartRate,
    this.medication,
    this.allergies,
    this.diseases,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'phoneNumber': phoneNumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'assignedChwId': assignedChwId,
      'assignedChwName': assignedChwName,
      'riskLevel': riskLevel,
      'status': status,
      'hasScheduledAppointment': hasScheduledAppointment,
      'createdAt': createdAt.toIso8601String(),
      'nextVisitDate': nextVisitDate?.toIso8601String(),
      'lastVisitDate': lastVisitDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'bloodSugar': bloodSugar,
      'bodyTemp': bodyTemp,
      'heartRate': heartRate,
      'medication': medication,
      'allergies': allergies,
      'diseases': diseases,
    };
  }

  factory MotherModel.fromJson(Map<String, dynamic> json) {
    return MotherModel(
      id: json['id']?.toString() ?? '',
      fullName: json['name'] ?? json['fullName'] ?? '',
      age: json['age'] ?? 25,
      phoneNumber: json['phone'] ?? json['phoneNumber'] ?? '',
      address: '${json['district'] ?? ''}, ${json['sector'] ?? ''}, ${json['village'] ?? ''}',
      emergencyContact: json['emergencyContact'] ?? json['phone'] ?? '',
      assignedChwId: json['created_by_chw_id']?.toString() ?? json['assignedChwId'] ?? '',
      assignedChwName: json['assignedChwName'] ?? 'CHW',
      riskLevel: json['current_risk_level'] ?? json['riskLevel'] ?? 'Not Predicted',
      status: json['status'] ?? 'active',
      hasScheduledAppointment: json['hasScheduledAppointment'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      nextVisitDate: json['nextVisitDate'] != null
          ? DateTime.parse(json['nextVisitDate'])
          : null,
      lastVisitDate: json['lastVisitDate'] != null
          ? DateTime.parse(json['lastVisitDate'])
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      systolicBP: json['systolicBP'],
      diastolicBP: json['diastolicBP'],
      bloodSugar: json['bloodSugar']?.toDouble(),
      bodyTemp: json['bodyTemp']?.toDouble(),
      heartRate: json['heartRate'],
      medication: json['medication'],
      allergies: json['allergies'],
      diseases: json['diseases'],
    );
  }

  MotherModel copyWith({
    String? id,
    String? fullName,
    int? age,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? assignedChwId,
    String? assignedChwName,
    String? riskLevel,
    String? status,
    bool? hasScheduledAppointment,
    DateTime? createdAt,
    DateTime? nextVisitDate,
    DateTime? lastVisitDate,
    DateTime? dueDate,
    int? systolicBP,
    int? diastolicBP,
    double? bloodSugar,
    double? bodyTemp,
    int? heartRate,
    String? medication,
    String? allergies,
    String? diseases,
  }) {
    return MotherModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      assignedChwId: assignedChwId ?? this.assignedChwId,
      assignedChwName: assignedChwName ?? this.assignedChwName,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      hasScheduledAppointment: hasScheduledAppointment ?? this.hasScheduledAppointment,
      createdAt: createdAt ?? this.createdAt,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      dueDate: dueDate ?? this.dueDate,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      bodyTemp: bodyTemp ?? this.bodyTemp,
      heartRate: heartRate ?? this.heartRate,
      medication: medication ?? this.medication,
      allergies: allergies ?? this.allergies,
      diseases: diseases ?? this.diseases,
    );
  }

  // Helper to convert to JSON string
  String toJsonString() => json.encode(toJson());

  // Helper to create from JSON string
  factory MotherModel.fromJsonString(String jsonString) {
    return MotherModel.fromJson(json.decode(jsonString));
  }
}
