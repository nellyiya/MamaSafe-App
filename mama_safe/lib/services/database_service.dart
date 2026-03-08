import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Database Service - Simple local storage service
/// Provides basic CRUD operations using SharedPreferences
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Generic methods for local storage
  Future<List<Map<String, dynamic>>> getAll(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(key);
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> save(String key, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(data));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> add(String key, Map<String, dynamic> item) async {
    try {
      final items = await getAll(key);
      items.add(item);
      return await save(key, items);
    } catch (e) {
      return false;
    }
  }

  Future<bool> update(String key, String id, Map<String, dynamic> item) async {
    try {
      final items = await getAll(key);
      final index = items.indexWhere((i) => i['id'] == id);
      if (index != -1) {
        items[index] = item;
        return await save(key, items);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> delete(String key, String id) async {
    try {
      final items = await getAll(key);
      items.removeWhere((i) => i['id'] == id);
      return await save(key, items);
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getById(String key, String id) async {
    try {
      final items = await getAll(key);
      return items.firstWhere((i) => i['id'] == id, orElse: () => {});
    } catch (e) {
      return null;
    }
  }

  // User-specific methods
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await getAll('allUsers');
  }

  Future<bool> updateUserStatus(String userId, bool isApproved) async {
    try {
      final users = await getAllUsers();
      final index = users.indexWhere((u) => u['id'] == userId);
      if (index != -1) {
        users[index]['isApproved'] = isApproved;
        return await save('allUsers', users);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    return await delete('allUsers', userId);
  }

  Future<int> getUserCount() async {
    final users = await getAllUsers();
    return users.length;
  }

  Future<int> getPendingUsersCount() async {
    final users = await getAllUsers();
    return users.where((u) => u['isApproved'] == false).length;
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final users = await getAllUsers();
    return users.where((u) => u['role'] == role).toList();
  }
}
