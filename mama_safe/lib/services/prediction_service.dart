import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Prediction Service - Handles risk prediction using ML model
/// Connects to FastAPI backend at http://127.0.0.1:8000/predict
class PredictionService {
  // Backend URL - matches ApiService configuration
  static const String _baseUrl = 'http://localhost:8000';
  // For Android emulator, use: 'http://10.0.2.2:8000'
  // For physical device, use your computer's IP: 'http://192.168.x.x:8000'

  // Singleton pattern
  static final PredictionService _instance = PredictionService._internal();
  factory PredictionService() => _instance;
  PredictionService._internal();

  /// Predict risk level based on health parameters
  ///
  /// Parameters:
  /// - age: Mother's age
  /// - systolicBP: Systolic blood pressure (mmHg)
  /// - diastolicBP: Diastolic blood pressure (mmHg)
  /// - bloodSugar: Blood sugar level (mmol/L)
  /// - bodyTemp: Body temperature (°C)
  /// - heartRate: Heart rate (bpm)
  ///
  /// Returns: Risk level - "Low", "Mid", or "High"
  Future<String> predictRisk({
    required int age,
    required int systolicBP,
    required int diastolicBP,
    required double bloodSugar,
    required double bodyTemp,
    required int heartRate,
  }) async {
    try {
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'Age': age,
        'SystolicBP': systolicBP,
        'DiastolicBP': diastolicBP,
        'BS': bloodSugar,
        'BodyTemp': bodyTemp,
        'HeartRate': heartRate,
      };

      print('🔮 Prediction Request: $requestBody');
      print('🌐 Connecting to: $_baseUrl/predict');

      // Make POST request to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Make sure backend is running on $_baseUrl');
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      // Check if request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? riskLevel = responseData['risk_level'];

        if (riskLevel != null) {
          // Normalize risk level: "low risk" -> "Low", "mid risk"/"medium" -> "Mid", "high risk" -> "High"
          final lowerRisk = riskLevel.toLowerCase();
          if (lowerRisk.contains('low')) return 'Low';
          if (lowerRisk.contains('mid') || lowerRisk.contains('medium')) return 'Mid';
          if (lowerRisk.contains('high')) return 'High';
          throw Exception('Invalid risk level received from server: $riskLevel');
        } else {
          throw Exception('No risk level in response');
        }
      } else {
        throw Exception(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception('Cannot connect to server. Make sure backend is running on $_baseUrl');
    } on FormatException {
      throw Exception('Invalid response from server');
    } catch (e) {
      print('❌ Prediction error: $e');
      rethrow;
    }
  }

  /// Get risk factors explanation
  String getRiskExplanation({
    required int age,
    required int systolicBP,
    required int diastolicBP,
    required double bloodSugar,
    required double bodyTemp,
    required int heartRate,
  }) {
    List<String> factors = [];

    if (systolicBP > 140 || diastolicBP > 90) {
      factors.add("High blood pressure detected");
    }

    if (bloodSugar > 7.0) {
      factors.add("Elevated blood sugar levels");
    }

    if (bodyTemp > 38.0) {
      factors.add("Fever detected");
    }

    if (heartRate > 120) {
      factors.add("Elevated heart rate");
    }

    if (factors.isEmpty) {
      return "All vital signs are within normal range";
    }

    return "Risk factors: ${factors.join(", ")}";
  }

  /// Get recommended actions based on risk level
  List<String> getRecommendedActions(String riskLevel) {
    switch (riskLevel) {
      case "High":
        return [
          "Immediate referral to healthcare facility",
          "Monitor blood pressure every 2 hours",
          "Check blood sugar levels regularly",
          "Schedule ultrasound examination",
          "Consider hospitalization if symptoms worsen",
        ];
      case "Mid":
        return [
          "Attend weekly prenatal checkups",
          "Monitor blood pressure regularly",
          "Maintain a balanced and nutritious diet",
          "Monitor blood sugar if advised by a healthcare professional",
          "Avoid strenuous physical activity",
        ];
      case "Low":
        return [
          "Continue regular prenatal care",
          "Monthly checkups",
          "Maintain healthy diet",
          "Light exercise as recommended",
        ];
      default:
        return ["Complete risk assessment first"];
    }
  }
}
