import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userJson = prefs.getString(AppConstants.userKey);

      if (token != null && userJson != null) {
        if (_isTokenValid(token)) {
          _token = token;
          _user = User.fromJson(json.decode(userJson));
          _isAuthenticated = true;
          ApiService.setAuthToken(token);
        } else {
          await _clearStoredAuth();
        }
      }
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
      await _clearStoredAuth();
    }
    notifyListeners();
  }

  bool _isTokenValid(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'];
      if (exp == null) return false;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await ApiService.login(email, password);
      
      _token = response['accessToken'];
      _user = User(
        id: response['id'],
        name: response['name'],
        email: response['email'],
        role: response['role'],
        verified: true,
      );
      _isAuthenticated = true;

      await _storeAuth();
      ApiService.setAuthToken(_token!);
      
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      await ApiService.register(userData);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    _setLoading(true);
    try {
      await ApiService.verifyOTP(email, otp);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOTP(String email) async {
    _setLoading(true);
    try {
      await ApiService.resendOTP(email);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    try {
      await ApiService.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;
    
    await _clearStoredAuth();
    ApiService.clearAuthToken();
    
    notifyListeners();
  }

  Future<void> _storeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, _token!);
      await prefs.setString(AppConstants.userKey, json.encode(_user!.toJson()));
    } catch (e) {
      debugPrint('Error storing auth: $e');
    }
  }

  Future<void> _clearStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
    } catch (e) {
      debugPrint('Error clearing stored auth: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    try {
      switch (_user?.role) {
        case 'STUDENT':
          await ApiService.updateStudentProfile(profileData);
          break;
        case 'PROFESSOR':
          await ApiService.updateProfessorProfile(profileData);
          break;
        case 'ALUMNI':
          await ApiService.updateAlumniProfile(profileData);
          break;
      }
      
      await _reloadUserData();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _reloadUserData() async {
    if (_user == null) return;
    
    try {
      Map<String, dynamic> profileData;
      switch (_user!.role) {
        case 'STUDENT':
          profileData = await ApiService.getStudentProfile(_user!.id);
          break;
        case 'PROFESSOR':
          profileData = await ApiService.getProfessorProfile(_user!.id);
          break;
        case 'ALUMNI':
          profileData = await ApiService.getAlumniProfile(_user!.id);
          break;
        default:
          return;
      }
      
      _user = User.fromJson({..._user!.toJson(), ...profileData});
      await _storeAuth();
      notifyListeners();
    } catch (e) {
      debugPrint('Error reloading user data: $e');
    }
  }
}