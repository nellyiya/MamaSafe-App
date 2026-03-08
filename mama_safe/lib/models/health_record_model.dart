class HealthRecord {
  final int id;
  final int motherId;
  final int age;
  final int systolicBP;
  final int diastolicBP;
  final double bloodSugar;
  final double bodyTemp;
  final int heartRate;
  final String riskLevel;
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.motherId,
    required this.age,
    required this.systolicBP,
    required this.diastolicBP,
    required this.bloodSugar,
    required this.bodyTemp,
    required this.heartRate,
    required this.riskLevel,
    required this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      motherId: json['mother_id'],
      age: json['age'],
      systolicBP: json['systolic_bp'],
      diastolicBP: json['diastolic_bp'],
      bloodSugar: json['blood_sugar'].toDouble(),
      bodyTemp: json['body_temp'].toDouble(),
      heartRate: json['heart_rate'],
      riskLevel: json['risk_level'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mother_id': motherId,
      'age': age,
      'systolic_bp': systolicBP,
      'diastolic_bp': diastolicBP,
      'blood_sugar': bloodSugar,
      'body_temp': bodyTemp,
      'heart_rate': heartRate,
      'risk_level': riskLevel,
    };
  }
}
