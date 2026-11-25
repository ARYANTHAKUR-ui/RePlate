
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/auth_storage.dart';
import '../../features/food/food_item.dart';

class ApiService {
  // Chrome/web runs on the same computer as the backend.
  // Android emulator uses 10.0.2.2 instead of localhost.
  // Physical phones need your computer's current Wi-Fi IPv4 address.
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000/api'
      : 'http://10.45.154.214:3000/api';

  static Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
  };

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please log in again to continue.');
    }

    return {
      ..._jsonHeaders,
      'Authorization': 'Bearer $token',
    };
  }

  // ========================================
  // GET AVAILABLE FOOD DONATIONS
  // GET /api/food
  // ========================================
  static Future<List<FoodItem>> getFoods() async {
    final url = Uri.parse('$baseUrl/food');

    debugPrint('REPLATE: Fetching available donations from $url');

    try {
      final response = await http.get(url);
      final result = _decodeResponse(response);
      final donations = result['data'] as List<dynamic>? ?? [];

      return donations
          .map(
            (item) => FoodItem.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    } catch (e) {
      debugPrint('REPLATE: getFoods error = $e');
      rethrow;
    }
  }

  // ========================================
  // GET MY HOTEL DONATIONS
  // GET /api/food/mine
  // ========================================
  static Future<List<FoodItem>> getMyFoods() async {
    final url = Uri.parse('$baseUrl/food/mine');

    debugPrint('REPLATE: Fetching hotel donations from $url');

    try {
      final response = await http.get(
        url,
        headers: await _authHeaders(),
      );

      final result = _decodeResponse(response);
      final donations = result['data'] as List<dynamic>? ?? [];

      return donations
          .map(
            (item) => FoodItem.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    } catch (e) {
      debugPrint('REPLATE: getMyFoods error = $e');
      rethrow;
    }
  }

  // ========================================
  // GET MY ACCEPTED NGO DONATIONS
  // GET /api/food/accepted
  // ========================================
  static Future<List<FoodItem>> getAcceptedFoods() async {
    final url = Uri.parse('$baseUrl/food/accepted');

    debugPrint('REPLATE: Fetching accepted donations from $url');

    try {
      final response = await http.get(
        url,
        headers: await _authHeaders(),
      );

      final result = _decodeResponse(response);
      final donations = result['data'] as List<dynamic>? ?? [];

      return donations
          .map(
            (item) => FoodItem.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    } catch (e) {
      debugPrint('REPLATE: getAcceptedFoods error = $e');
      rethrow;
    }
  }

  // ========================================
  // ACCEPT A FOOD DONATION
  // PATCH /api/food/:id/accept
  // NGO only
  // ========================================
  static Future<FoodItem> acceptFood(String foodId) async {
    final url = Uri.parse('$baseUrl/food/$foodId/accept');

    debugPrint('REPLATE: Accepting donation $foodId');

    try {
      final response = await http.patch(
        url,
        headers: await _authHeaders(),
      );

      final result = _decodeResponse(response);

      return FoodItem.fromJson(
        result['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('REPLATE: acceptFood error = $e');
      rethrow;
    }
  }

  // ========================================
  // MARK FOOD AS COLLECTED
  // PATCH /api/food/:id/collect
  // NGO that accepted it only
  // ========================================
  static Future<FoodItem> markFoodCollected(String foodId) async {
    final url = Uri.parse('$baseUrl/food/$foodId/collect');

    debugPrint('REPLATE: Marking donation $foodId as collected');

    try {
      final response = await http.patch(
        url,
        headers: await _authHeaders(),
      );

      final result = _decodeResponse(response);

      return FoodItem.fromJson(
        result['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('REPLATE: markFoodCollected error = $e');
      rethrow;
    }
  }

  // ========================================
  // CREATE FOOD DONATION
  // POST /api/food
  // Hotel only
  // ========================================
  static Future<FoodItem> createFood(FoodItem food) async {
    final url = Uri.parse('$baseUrl/food');

    debugPrint('REPLATE: Publishing donation to $url');

    try {
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({
          'name': food.name,
          'peopleCount': food.peopleCount,
          'category': food.category,
          'providerName': food.providerName,
          'location': food.location,
          'description': food.description,
          'expiresAt': food.expiresAt.toUtc().toIso8601String(),
          'latitude': food.latitude,
          'longitude': food.longitude,
        }),
      );

      final result = _decodeResponse(response);

      return FoodItem.fromJson(
        result['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('REPLATE: createFood error = $e');
      rethrow;
    }
  }

  // ========================================
  // DELETE FOOD DONATION
  // DELETE /api/food/:id
  // Hotel owner only
  // ========================================
  static Future<void> deleteFood(String id) async {
    final url = Uri.parse('$baseUrl/food/$id');

    debugPrint('REPLATE: Deleting donation $id');

    try {
      final response = await http.delete(
        url,
        headers: await _authHeaders(),
      );

      _decodeResponse(response);
    } catch (e) {
      debugPrint('REPLATE: deleteFood error = $e');
      rethrow;
    }
  }

  // ========================================
  // REGISTER ACCOUNT
  // POST /api/auth/register
  // ========================================
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    debugPrint('REPLATE: Registering account');

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final result = _decodeResponse(response);

      final token = result['token'];
      final user = result['user'];

      if (token is String && user is Map<String, dynamic>) {
        await AuthStorage.saveSession(
          token: token,
          user: user,
        );
      }

      return result;
    } catch (e) {
      debugPrint('REPLATE: register error = $e');
      rethrow;
    }
  }

  // ========================================
  // LOGIN ACCOUNT
  // POST /api/auth/login
  // ========================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    debugPrint('REPLATE: Logging in');

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final result = _decodeResponse(response);

      final token = result['token'];
      final user = result['user'];

      if (token is String && user is Map<String, dynamic>) {
        await AuthStorage.saveSession(
          token: token,
          user: user,
        );
      }

      return result;
    } catch (e) {
      debugPrint('REPLATE: login error = $e');
      rethrow;
    }
  }

  // ========================================
  // DECODE SERVER RESPONSE
  // ========================================
  static Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    Map<String, dynamic> result;

    try {
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Server returned an invalid response '
            '(HTTP ${response.statusCode}).',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return result;
    }

    final message = result['message'] ??
        result['error'] ??
        'Request failed with HTTP ${response.statusCode}.';

    throw Exception(message.toString());
  }
}
