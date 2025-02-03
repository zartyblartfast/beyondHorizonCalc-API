/// Configuration for the API calculator
class ApiConfig {
  /// Base URL for the API
  static const String baseUrl = 'http://localhost:7071';  // Local testing URL

  /// Calculate endpoint path
  static const String calculateEndpoint = '/api/calculate';  // Include api prefix

  /// Full URL for the calculate endpoint
  static String get calculateUrl => '$baseUrl$calculateEndpoint';

  /// Timeout duration for API requests in seconds
  static const int timeoutSeconds = 10;
}
