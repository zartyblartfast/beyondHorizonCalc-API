import 'package:flutter/foundation.dart';

/// Enum defining the available calculation modes
enum CalculationMode {
  /// Use local calculations
  local,
  
  /// Use API calculations
  api,
}

/// Service for managing calculation configuration
class CalculationConfig {
  static final ValueNotifier<CalculationMode> _modeNotifier = ValueNotifier(CalculationMode.local);

  /// Initialize the configuration service
  static Future<void> initialize() async {
    // No initialization needed with ValueNotifier
    return Future.value();
  }

  /// Get the current calculation mode
  static CalculationMode get mode => _modeNotifier.value;

  /// Set the calculation mode
  static Future<void> setMode(CalculationMode newMode) async {
    _modeNotifier.value = newMode;
  }

  /// Check if using API calculations
  static bool get isUsingApi => mode == CalculationMode.api;

  /// Get a display string for the current mode
  static String get modeDisplayString => 
      mode == CalculationMode.api ? 'API' : 'Local';
      
  /// Get the ValueNotifier for listening to mode changes
  static ValueNotifier<CalculationMode> get modeNotifier => _modeNotifier;
}
