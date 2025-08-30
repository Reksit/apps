import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';
import '../models/user.dart';
import '../models/job.dart';
import '../models/event.dart';
import '../models/assessment.dart';

class ApiService {
  static late Dio _dio;
  static String? _authToken;

  static void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        debugPrint('API Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('API Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
        if (error.response?.statusCode == 401) {
          // Token expired, clear auth
          clearAuthToken();
        }
        handler.next(error);
      },
    ));
  }

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  // Authentication APIs
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/signin', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/signup', data: userData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> verifyOTP(String email, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> resendOTP(String email) async {
    try {
      final response = await _dio.post('/auth/resend-otp', 
        queryParameters: {'email': email}
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _dio.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return response.data['message'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Student APIs
  static Future<Map<String, dynamic>> getStudentProfile(String userId) async {
    try {
      final response = await _dio.get('/students/profile/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getMyStudentProfile() async {
    try {
      final response = await _dio.get('/students/my-profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> updateStudentProfile(Map<String, dynamic> profileData) async {
    try {
      await _dio.put('/students/my-profile', data: profileData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Professor APIs
  static Future<Map<String, dynamic>> getProfessorProfile(String userId) async {
    try {
      final response = await _dio.get('/professors/profile/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> updateProfessorProfile(Map<String, dynamic> profileData) async {
    try {
      await _dio.put('/professors/my-profile', data: profileData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Alumni APIs
  static Future<Map<String, dynamic>> getAlumniProfile(String userId) async {
    try {
      final response = await _dio.get('/alumni/profile/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getMyAlumniProfile() async {
    try {
      final response = await _dio.get('/alumni/my-profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> updateAlumniProfile(Map<String, dynamic> profileData) async {
    try {
      await _dio.put('/alumni/my-profile', data: profileData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getAlumniDirectory() async {
    try {
      final response = await _dio.get('/api/alumni-directory');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getAlumniStats() async {
    try {
      final response = await _dio.get('/alumni/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Job APIs
  static Future<List<Job>> getAllJobs() async {
    try {
      final response = await _dio.get('/jobs');
      return (response.data as List)
          .map((job) => Job.fromJson(job))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Job> createJob(Map<String, dynamic> jobData) async {
    try {
      final response = await _dio.post('/jobs', data: jobData);
      return Job.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Job> updateJob(String jobId, Map<String, dynamic> jobData) async {
    try {
      final response = await _dio.put('/jobs/$jobId', data: jobData);
      return Job.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> deleteJob(String jobId) async {
    try {
      await _dio.delete('/jobs/$jobId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Job>> searchJobs(String query) async {
    try {
      final response = await _dio.get('/jobs/search', queryParameters: {'query': query});
      return (response.data as List)
          .map((job) => Job.fromJson(job))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Event APIs
  static Future<List<Event>> getApprovedEvents() async {
    try {
      final response = await _dio.get('/api/events/approved');
      return (response.data as List)
          .map((event) => Event.fromJson(event))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> submitEventRequest(Map<String, dynamic> eventData) async {
    try {
      final response = await _dio.post('/api/alumni-events/request', data: eventData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> updateEventAttendance(String eventId, bool attending) async {
    try {
      await _dio.post('/api/events/$eventId/attendance', data: {
        'attending': attending,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Assessment APIs
  static Future<Assessment> generateAIAssessment(Map<String, dynamic> requestData) async {
    try {
      final response = await _dio.post('/assessments/generate-ai', data: requestData);
      return Assessment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Assessment>> getStudentAssessments() async {
    try {
      final response = await _dio.get('/assessments/student');
      return (response.data as List)
          .map((assessment) => Assessment.fromJson(assessment))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Assessment>> getProfessorAssessments() async {
    try {
      final response = await _dio.get('/assessments/professor');
      return (response.data as List)
          .map((assessment) => Assessment.fromJson(assessment))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<AssessmentResult> submitAssessment(
    String assessmentId, 
    Map<String, dynamic> submission
  ) async {
    try {
      final response = await _dio.post('/assessments/$assessmentId/submit', data: submission);
      return AssessmentResult.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Assessment> createAssessment(Map<String, dynamic> assessmentData) async {
    try {
      final response = await _dio.post('/assessments', data: assessmentData);
      return Assessment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    try {
      final response = await _dio.get('/assessments/search-students', 
        queryParameters: {'query': query}
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Chat APIs
  static Future<String> sendAIMessage(String message) async {
    try {
      final response = await _dio.post('/chat/ai', data: {'message': message});
      return response.data['response'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getChatConversations() async {
    try {
      final response = await _dio.get('/chat/conversations');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getAllChatUsers() async {
    try {
      final response = await _dio.get('/chat/users');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> sendMessage(String receiverId, String message) async {
    try {
      final response = await _dio.post('/chat/send', data: {
        'receiverId': receiverId,
        'message': message,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
    try {
      final response = await _dio.get('/chat/history/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Management APIs
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/management/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getAlumniApplications() async {
    try {
      final response = await _dio.get('/management/alumni');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> approveAlumni(String alumniId, bool approved) async {
    try {
      final response = await _dio.put('/management/alumni/$alumniId/status', data: {
        'approved': approved,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Event>> getAllAlumniEventRequests() async {
    try {
      final response = await _dio.get('/management/alumni-event-requests');
      return (response.data as List)
          .map((event) => Event.fromJson(event))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> approveAlumniEventRequest(String requestId) async {
    try {
      final response = await _dio.post('/management/alumni-event-requests/$requestId/approve');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> rejectAlumniEventRequest(String requestId, String reason) async {
    try {
      final response = await _dio.post('/management/alumni-event-requests/$requestId/reject', data: {
        'reason': reason,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Connection APIs
  static Future<Map<String, dynamic>> sendConnectionRequest(String recipientId, String message) async {
    try {
      final response = await _dio.post('/connections/send-request', data: {
        'recipientId': recipientId,
        'message': message,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingConnectionRequests() async {
    try {
      final response = await _dio.get('/connections/pending');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> acceptConnectionRequest(String connectionId) async {
    try {
      final response = await _dio.post('/connections/$connectionId/accept');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> rejectConnectionRequest(String connectionId) async {
    try {
      final response = await _dio.post('/connections/$connectionId/reject');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Task APIs
  static Future<List<Map<String, dynamic>>> getUserTasks() async {
    try {
      final response = await _dio.get('/tasks');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _dio.post('/tasks', data: taskData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> generateRoadmap(String taskId) async {
    try {
      final response = await _dio.post('/tasks/$taskId/roadmap');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updateTaskStatus(String taskId, String status) async {
    try {
      final response = await _dio.put('/tasks/$taskId/status', data: {'status': status});
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Notification APIs
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _dio.get('/notifications/count');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Activity APIs
  static Future<void> logActivity(String type, String description) async {
    try {
      await _dio.post('/activities', data: {
        'type': type,
        'description': description,
      });
    } on DioException catch (e) {
      // Don't throw error for activity logging to avoid disrupting main functionality
      debugPrint('Failed to log activity: $e');
    }
  }

  static Future<Map<String, dynamic>> getHeatmapData(String userId) async {
    try {
      final response = await _dio.get('/activities/heatmap/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  static String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'];
      } else if (data is String) {
        return data;
      }
      return 'Server error: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Connection error. Please check your internet connection.';
    } else {
      return 'Network error. Please try again.';
    }
  }
}