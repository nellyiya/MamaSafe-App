import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use localhost for web/physical device, 10.0.2.2 for Android emulator
  static const String baseUrl = 'http://localhost:8000'; // Web/Chrome
  // For Android emulator, use: 'http://10.0.2.2:8000'
  // For physical device, use your computer's IP: 'http://192.168.x.x:8000'
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {'Content-Type': 'application/json'};
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? district,
    String? sector,
    String? cell,
    String? village,
    String? facility,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'district': district,
        'sector': sector,
        'cell': cell,
        'village': village,
        'facility': facility,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Registration failed');
    }
  }

  Future<String> login(String email, String password) async {
    print('🌐 API: Attempting login to $baseUrl/auth/login');
    print('📧 Email: $email');
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      await saveToken(token);
      print('✅ Token saved');
      return token;
    } else {
      final error = jsonDecode(response.body)['detail'] ?? 'Login failed';
      print('❌ Login failed: $error');
      throw Exception(error);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user info');
    }
  }

  // Mother endpoints
  Future<Map<String, dynamic>> createMother(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mothers'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Failed to create mother');
    }
  }

  Future<List<dynamic>> getMothers() async {
    print('👩 API: Fetching mothers from $baseUrl/mothers');
    final response = await http.get(
      Uri.parse('$baseUrl/mothers'),
      headers: _getHeaders(),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Mothers loaded: ${data.length} items');
      return data;
    } else {
      print('❌ Failed to get mothers: ${response.body}');
      throw Exception('Failed to get mothers');
    }
  }

  Future<Map<String, dynamic>> getMother(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mothers/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get mother');
    }
  }

  // Health record endpoints
  Future<Map<String, dynamic>> createHealthRecord(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/health-records'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create health record');
    }
  }

  Future<List<dynamic>> getHealthRecords(int motherId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/health-records/$motherId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get health records');
    }
  }

  // Visit endpoints
  Future<Map<String, dynamic>> createVisit(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visits'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create visit');
    }
  }

  Future<List<dynamic>> getVisitsDueToday() async {
    final response = await http.get(
      Uri.parse('$baseUrl/visits/due-today'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get visits');
    }
  }

  Future<List<dynamic>> getOverdueVisits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/visits/overdue'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get overdue visits');
    }
  }

  // Referral endpoints
  Future<Map<String, dynamic>> predictWithReferral({
    required int motherId,
    required int age,
    required int systolicBP,
    required int diastolicBP,
    required double bloodSugar,
    required double bodyTemp,
    required int heartRate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict-with-referral?mother_id=$motherId'),
      headers: _getHeaders(),
      body: jsonEncode({
        'Age': age,
        'SystolicBP': systolicBP,
        'DiastolicBP': diastolicBP,
        'BS': bloodSugar,
        'BodyTemp': bodyTemp,
        'HeartRate': heartRate,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to predict with referral');
    }
  }

  Future<Map<String, dynamic>> createReferral(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/referrals'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create referral');
    }
  }

  Future<List<dynamic>> getIncomingReferrals() async {
    print('🏛️ API: Fetching incoming referrals from $baseUrl/referrals/incoming');
    final response = await http.get(
      Uri.parse('$baseUrl/referrals/incoming'),
      headers: _getHeaders(),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body length: ${response.body.length}');
    if (response.body.length < 500) {
      print('📊 Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Referrals loaded: ${data.length} items');
      return data;
    } else {
      print('❌ Failed to get referrals: ${response.body}');
      throw Exception('Failed to get referrals');
    }
  }

  Future<Map<String, dynamic>> updateReferral(int id, Map<String, dynamic> data) async {
    print('🔄 API: Updating referral $id with data: $data');
    final response = await http.put(
      Uri.parse('$baseUrl/referrals/$id'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Referral updated successfully');
      return jsonDecode(response.body);
    } else {
      print('❌ Failed to update referral: ${response.body}');
      throw Exception('Failed to update referral');
    }
  }

  // Dashboard endpoints
  Future<Map<String, dynamic>> getCHWDashboard() async {
    print('📊 API: Fetching CHW dashboard from $baseUrl/dashboard/chw');
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/chw'),
      headers: _getHeaders(),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ CHW Dashboard loaded successfully');
      return data;
    } else {
      print('❌ Failed to get CHW dashboard: ${response.body}');
      throw Exception('Failed to get dashboard');
    }
  }

  Future<Map<String, dynamic>> getHealthcareProDashboard() async {
    print('🏛️ API: Fetching healthcare pro dashboard from $baseUrl/dashboard/healthcare-pro');
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/healthcare-pro'),
      headers: _getHeaders(),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Dashboard loaded successfully');
      return data;
    } else {
      print('❌ Failed to get dashboard: ${response.body}');
      throw Exception('Failed to get dashboard');
    }
  }

  // Admin endpoints
  Future<List<dynamic>> getPendingUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/pending'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get pending users');
    }
  }

  Future<void> approveUser(int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/approve'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve user');
    }
  }

  Future<void> rejectUser(int userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/reject'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reject user');
    }
  }

  Future<Map<String, dynamic>> getAdminDashboard({int days = 30}) async {
    print('📊 API: Fetching admin dashboard from $baseUrl/admin/dashboard?days=$days');
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard?days=$days'),
      headers: _getHeaders(),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Admin Dashboard loaded successfully');
      return data;
    } else {
      print('❌ Failed to get admin dashboard: ${response.body}');
      throw Exception('Failed to get admin dashboard');
    }
  }

  Future<List<dynamic>> getCHWPerformance({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/chw-performance?days=$days'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get CHW performance');
    }
  }

  Future<List<dynamic>> getHospitalPerformance({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/hospital-performance?days=$days'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get hospital performance');
    }
  }

  Future<Map<String, dynamic>> getRiskTrends({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/analytics/risk-trends?days=$days'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get risk trends');
    }
  }

  Future<Map<String, dynamic>> getReferralDistribution({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/analytics/referral-distribution?days=$days'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get referral distribution');
    }
  }

  Future<List<dynamic>> getCHWActivity({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/analytics/chw-activity?days=$days'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get CHW activity');
    }
  }

  Future<List<dynamic>> getHospitalWorkload({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/analytics/hospital-workload?days=$days'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get hospital workload');
    }
  }

  Future<List<dynamic>> getAllReferrals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/referrals/all'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get all referrals');
    }
  }

  // Admin CRUD endpoints
  Future<List<dynamic>> getCHWs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/chws'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get CHWs');
    }
  }

  Future<List<dynamic>> getHealthcarePros() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/healthcare-pros'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get healthcare professionals');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<List<dynamic>> getAllMothersAdmin() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/mothers/all'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get mothers');
    }
  }

  Future<void> updateMother(int motherId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/mothers/$motherId'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update mother');
    }
  }

  Future<void> deleteMother(int motherId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/mothers/$motherId'),
      headers: _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete mother');
    }
  }

  Future<List<dynamic>> getReferrals() async {
    return await getAllReferrals();
  }

  Future<List<dynamic>> getAppointments() async {
    final referrals = await getAllReferrals();
    return referrals.where((r) => r['status'] == 'APPOINTMENT_SCHEDULED' || r['status'] == 'Appointment Scheduled').toList();
  }

  Future<List<dynamic>> getHealthcareProfessionals() async {
    return await getHealthcarePros();
  }

  Future<List<dynamic>> getFacilities() async {
    final pros = await getHealthcarePros();
    final facilities = <String, Map<String, dynamic>>{};
    for (var pro in pros) {
      final facility = pro['facility'] ?? 'Unknown';
      if (!facilities.containsKey(facility)) {
        facilities[facility] = {
          'name': facility,
          'staff_count': 0,
          'referrals_count': 0,
        };
      }
      facilities[facility]!['staff_count'] = (facilities[facility]!['staff_count'] as int) + 1;
      facilities[facility]!['referrals_count'] = (facilities[facility]!['referrals_count'] as int) + (pro['referrals_count'] ?? 0);
    }
    return facilities.values.toList();
  }
}
