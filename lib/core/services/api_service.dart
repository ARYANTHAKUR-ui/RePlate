
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/food/food_item.dart';

class ApiService {
  // Android Emulator connects to your computer's localhost through 10.0.2.2.
  static const String baseUrl = 'http://192.168.16.114:3000/api';

  // --------------------------------------------------
  // GET ALL FOOD DONATIONS
  // --------------------------------------------------
  static Future<List<FoodItem>> getFoods() async {
    final url = Uri.parse('$baseUrl/food');

    debugPrint('REPLATE: Requesting donations from $url');

    try {
      final response = await http.get(url);

      debugPrint('REPLATE: HTTP status = ${response.statusCode}');
      debugPrint('REPLATE: Response body = ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load donations: HTTP ${response.statusCode}',
        );
      }

      final Map<String, dynamic> result =
      jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> donations =
          result['data'] as List<dynamic>? ?? [];

      debugPrint(
        'REPLATE: Donations received = ${donations.length}',
      );

      final foods = donations.map((json) {
        return FoodItem.fromJson(
          json as Map<String, dynamic>,
        );
      }).toList();

      return foods;
    } catch (e) {
      debugPrint('REPLATE: getFoods error = $e');
      rethrow;
    }
  }

  // --------------------------------------------------
  // CREATE FOOD DONATION
  // --------------------------------------------------
  static Future<FoodItem> createFood(FoodItem food) async {
    final url = Uri.parse('$baseUrl/food');

    debugPrint('REPLATE: Publishing donation to $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
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

    debugPrint(
      'REPLATE: Create food status = ${response.statusCode}',
    );
    debugPrint(
      'REPLATE: Create food response = ${response.body}',
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to publish donation: ${response.body}',
      );
    }

    final Map<String, dynamic> result =
    jsonDecode(response.body) as Map<String, dynamic>;

    return FoodItem.fromJson(
      result['data'] as Map<String, dynamic>,
    );
  }

  // --------------------------------------------------
  // REGISTER USER
  // --------------------------------------------------
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    debugPrint('REPLATE: Registering user at $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    debugPrint(
      'REPLATE: Register status = ${response.statusCode}',
    );
    debugPrint(
      'REPLATE: Register response = ${response.body}',
    );

    return _decodeResponse(response);
  }

  // --------------------------------------------------
  // LOGIN USER
  // --------------------------------------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    debugPrint('REPLATE: Logging in at $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    debugPrint(
      'REPLATE: Login status = ${response.statusCode}',
    );
    debugPrint(
      'REPLATE: Login response = ${response.body}',
    );

    return _decodeResponse(response);
  }

  // --------------------------------------------------
  // DECODE API RESPONSE
  // --------------------------------------------------
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

    final message =
        result['message'] ??
            result['error'] ??
            'Request failed with HTTP ${response.statusCode}';

    throw Exception(message.toString());
  }
}
