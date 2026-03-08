import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_strings.dart';
import '../services/api_service.dart';

/// User roles in the app - Using prefix to avoid conflicts
enum AppUserRole {
  chw,
  healthcareProfessional,
  admin,
}

/// User model for storing user data
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final AppUserRole role;
  final bool isApproved;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isApproved = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: AppUserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => AppUserRole.chw,
      ),
      isApproved: json['isApproved'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    AppUserRole? role,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Auth Provider - Manages user authentication and session
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;
  AppUserRole? _currentUserRole;
  bool _isApproved = false;
  List<UserModel> _allUsers = [];

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  AppUserRole? get currentUserRole => _currentUserRole;
  bool get isApproved => _isApproved;
  List<UserModel> get allUsers => _allUsers;

  // Get pending users
  List<UserModel> get pendingUsers =>
      _allUsers.where((u) => !u.isApproved).toList();

  // Get approved users
  List<UserModel> get approvedUsers =>
      _allUsers.where((u) => u.isApproved).toList();

  // Get users by role
  List<UserModel> getUsersByRole(AppUserRole role) =>
      _allUsers.where((u) => u.role == role).toList();

  // Get current user (for compatibility)
  Map<String, dynamic>? get currentUser {
    if (!_isAuthenticated) return null;
    return {
      'id': _currentUserId,
      'name': _currentUserName,
      'email': _currentUserEmail,
      'role': _currentUserRole?.name,
      'isApproved': _isApproved,
    };
  }

  // Get user role
  AppUserRole? get userRole => _currentUserRole;

  AuthProvider() {
    _loadAuthData();
    _loadAllUsers();
  }

  // Load all users from storage
  Future<void> _loadAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('allUsers');
      if (usersJson != null) {
        final List<dynamic> decoded = json.decode(usersJson);
        _allUsers = decoded.map((u) => UserModel.fromJson(u)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Save all users to storage
  Future<void> _saveAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = json.encode(_allUsers.map((u) => u.toJson()).toList());
      await prefs.setString('allUsers', usersJson);
    } catch (e) {
      // Handle error silently
    }
  }

  // Load saved auth data
  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _currentUserId = prefs.getString('userId');
      _currentUserName = prefs.getString('userName');
      _currentUserEmail = prefs.getString('userEmail');
      _isApproved = prefs.getBool('isApproved') ?? false;

      final roleString = prefs.getString('userRole');
      if (roleString != null) {
        _currentUserRole = AppUserRole.values.firstWhere(
          (role) => role.name == roleString.split('.').last,
          orElse: () => AppUserRole.chw,
        );
      }

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
    }
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔐 Attempting login for: $email');
      final apiService = ApiService();
      await apiService.login(email, password);
      print('✅ Login API call successful');
      
      final userData = await apiService.getCurrentUser();
      print('✅ Got user data: ${userData['name']}');
      
      _isAuthenticated = true;
      _currentUserId = userData['id'].toString();
      _currentUserName = userData['name'];
      _currentUserEmail = userData['email'];
      _isApproved = userData['is_approved'];
      
      final roleStr = userData['role'];
      if (roleStr == 'Admin') {
        _currentUserRole = AppUserRole.admin;
      } else if (roleStr == 'HealthcarePro') {
        _currentUserRole = AppUserRole.healthcareProfessional;
      } else {
        _currentUserRole = AppUserRole.chw;
      }

      await _saveAuthData();
      print('✅ Login complete!');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Login error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Sign up
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required AppUserRole role,
    required String password,
    String? district,
    String? sector,
    String? cell,
    String? village,
    String? facility,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = ApiService();
      String roleStr;
      if (role == AppUserRole.admin) {
        roleStr = 'Admin';
      } else if (role == AppUserRole.healthcareProfessional) {
        roleStr = 'HealthcarePro';
      } else {
        roleStr = 'CHW';
      }
      
      await apiService.register(
        name: fullName,
        email: email,
        phone: phone,
        password: password,
        role: roleStr,
        district: district,
        sector: sector,
        cell: cell,
        village: village,
        facility: facility,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Approve a user
  Future<bool> approveUser(String userId) async {
    try {
      final apiService = ApiService();
      await apiService.approveUser(int.parse(userId));
      await loadPendingUsers();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Reject a user (remove from list)
  Future<bool> rejectUser(String userId) async {
    try {
      final apiService = ApiService();
      await apiService.rejectUser(int.parse(userId));
      await loadPendingUsers();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Load pending users from API
  Future<void> loadPendingUsers() async {
    try {
      final apiService = ApiService();
      final users = await apiService.getPendingUsers();
      _allUsers = users.map((u) => UserModel(
        id: u['id'].toString(),
        name: u['name'],
        email: u['email'],
        phone: u['phone'],
        role: u['role'] == 'Admin' ? AppUserRole.admin : 
              u['role'] == 'HealthcarePro' ? AppUserRole.healthcareProfessional : AppUserRole.chw,
        isApproved: u['is_approved'],
        createdAt: DateTime.parse(u['created_at']),
      )).toList();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  // Get user by ID
  UserModel? getUserById(String userId) {
    try {
      return _allUsers.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUserId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _currentUserRole = null;
    _isApproved = false;

    try {
      final apiService = ApiService();
      await apiService.clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Handle error silently
    }

    notifyListeners();
  }

  // Save auth data
  Future<void> _saveAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', _isAuthenticated);
      if (_currentUserId != null) {
        await prefs.setString('userId', _currentUserId!);
      }
      if (_currentUserName != null) {
        await prefs.setString('userName', _currentUserName!);
      }
      if (_currentUserEmail != null) {
        await prefs.setString('userEmail', _currentUserEmail!);
      }
      if (_currentUserRole != null) {
        await prefs.setString('userRole', _currentUserRole.toString());
      }
      await prefs.setBool('isApproved', _isApproved);
    } catch (e) {
      // Handle error silently
    }
  }

  // Get role display name
  String getRoleDisplayName() {
    if (_currentUserRole == null) return '';

    switch (_currentUserRole!) {
      case AppUserRole.chw:
        return AppStrings.roleCHW;
      case AppUserRole.healthcareProfessional:
        return AppStrings.roleHealthcareProfessional;
      case AppUserRole.admin:
        return AppStrings.roleAdmin;
    }
  }

  // Check if user is CHW
  bool get isCHW => _currentUserRole == AppUserRole.chw;

  // Check if user is Healthcare Professional
  bool get isHealthcareProfessional =>
      _currentUserRole == AppUserRole.healthcareProfessional;

  // Check if user is Admin
  bool get isAdmin => _currentUserRole == AppUserRole.admin;

  // For backwards compatibility - provide UserRole type alias
  AppUserRole get userRoleType => _currentUserRole ?? AppUserRole.chw;

  // Refresh users list from storage
  Future<void> refreshUsers() async {
    await _loadAllUsers();
  }
}
