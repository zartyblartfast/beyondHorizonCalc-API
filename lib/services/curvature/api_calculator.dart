import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/calculation_result.dart';
import '../models/calculation_error.dart';
import 'base_calculator.dart';
import '../config/api_config.dart';

/// Calculator implementation that uses the API for calculations.
/// 
/// Note on API Response Format:
/// The API follows REST best practices and returns snake_case field names (e.g., 'horizon_distance').
/// This client converts the snake_case response to camelCase to match Flutter conventions.
/// We deliberately handle the conversion here rather than requesting different formats from the API
/// to maintain API consistency and future compatibility with other clients (Twitter bots, AI agents, etc.).
class ApiCurvatureCalculator extends BaseCalculator {
  /// HTTP client for making API requests
  final http.Client _client;

  /// Creates a new API calculator with an optional HTTP client
  ApiCurvatureCalculator([http.Client? client]) : _client = client ?? http.Client();

  @override
  Future<CalculationResult> calculate({
    required double observerHeight,
    required double distance,
    required double refractionFactor,
    required bool isMetric,
    double? targetHeight,
  }) async {
    try {
      // Convert inputs to metric for validation
      final (heightMeters, distanceKm, targetHeightMeters) = convertToMetric(
        observerHeight: observerHeight,
        distance: distance,
        isMetric: isMetric,
        targetHeight: targetHeight,
      );

      print('[API] Original values:');
      print('[API] - Observer Height: $observerHeight (isMetric: $isMetric)');
      print('[API] - Distance: $distance');
      print('[API] - Target Height: $targetHeight');
      
      print('[API] Converted values:');
      print('[API] - Observer Height: $heightMeters meters');
      print('[API] - Distance: $distanceKm km');
      print('[API] - Target Height: $targetHeightMeters meters');

      // Validate inputs
      if (!validateInputs(
        heightMeters: heightMeters,
        distanceKm: distanceKm,
        targetHeightMeters: targetHeightMeters,
      )) {
        return CalculationResult.error(
          CalculationError.invalidInput(
            'Input values are outside the valid range. Please check your inputs.',
          ),
        );
      }

      // Prepare request body with metric values
      final body = jsonEncode({
        'observerHeight': heightMeters,    // Use camelCase to match API
        'distance': distanceKm,
        'refractionFactor': refractionFactor,
        if (targetHeightMeters != null) 'targetHeight': targetHeightMeters,
        'isMetric': true,  // Always true since we're sending metric values
      });

      print('[API] Request body: $body');

      // Make API request
      final response = await _client
          .post(
            Uri.parse(ApiConfig.calculateUrl),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('API request timed out'),
          );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      if (response.statusCode != 200) {
        print('[API] Error response: ${response.body}');
        String message;
        try {
          final errorData = jsonDecode(response.body);
          message = errorData['error'] ?? 'Unknown API error';
        } catch (_) {
          message = 'API returned an error: ${response.statusCode}';
        }
        return CalculationResult.error(
          CalculationError.apiError(message, response.body),
        );
      }

      // Parse response and convert snake_case to camelCase
      final Map<String, dynamic> rawData = jsonDecode(response.body);
      final data = {
        'horizonDistance': rawData['horizon_distance'],
        'hiddenHeight': rawData['hidden_height'],
        'visibleTargetHeight': rawData['visible_target_height'],
        'apparentVisibleHeight': rawData['apparent_visible_height'],
        'perspectiveScaledHeight': rawData['perspective_scaled_height'],
      };
      
      return CalculationResult(
        horizonDistance: data['horizonDistance']?.toDouble(),
        hiddenHeight: data['hiddenHeight']?.toDouble(),
        visibleTargetHeight: data['visibleTargetHeight']?.toDouble(),
        apparentVisibleHeight: data['apparentVisibleHeight']?.toDouble(),
        perspectiveScaledHeight: data['perspectiveScaledHeight']?.toDouble(),
      );
    } on http.ClientException catch (e) {
      return CalculationResult.error(
        CalculationError.apiUnreachable(e.toString()),
      );
    } on TimeoutException {
      return CalculationResult.error(
        CalculationError.apiUnreachable('Request timed out'),
      );
    } catch (e) {
      return CalculationResult.error(
        CalculationError.apiError('An unexpected error occurred', e.toString()),
      );
    }
  }

  /// Helper to get value from JSON supporting both snake_case and camelCase
  T? _getValue<T>(Map<String, dynamic> json, String camelCaseKey) {
    // Try camelCase first (for preset compatibility)
    final camelValue = json[camelCaseKey];
    if (camelValue != null) return camelValue as T;
    
    // Try snake_case (for API compatibility)
    final snakeKey = camelCaseKey.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)?.toLowerCase()}'
    );
    return json[snakeKey] as T?;
  }

  /// Closes the HTTP client
  void dispose() {
    _client.close();
  }
}
