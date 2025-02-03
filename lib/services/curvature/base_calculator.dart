import '../models/calculation_result.dart';

/// Abstract interface for curvature calculators
abstract class BaseCalculator {
  /// Earth's radius in meters
  static const double EARTH_RADIUS_METERS = 6371000;

  /// Range limits (matching Python API)
  static const double MIN_OBSERVER_HEIGHT = 2.0;    // meters
  static const double MAX_OBSERVER_HEIGHT = 9000.0; // meters
  static const double MIN_DISTANCE = 5.0;           // kilometers
  static const double MAX_DISTANCE = 600.0;         // kilometers
  static const double MAX_TARGET_HEIGHT = 9000.0;   // meters

  /// Calculates earth curvature effects based on input parameters
  /// 
  /// [observerHeight] Height of observer in meters (metric) or feet (imperial)
  /// [distance] Distance in kilometers (metric) or miles (imperial)
  /// [refractionFactor] Atmospheric refraction factor (typically 1.07)
  /// [targetHeight] Optional target height in meters (metric) or feet (imperial)
  /// [isMetric] Whether the input values are in metric units
  /// 
  /// Returns [CalculationResult] containing all calculated values in meters and kilometers
  Future<CalculationResult> calculate({
    required double observerHeight,
    required double distance,
    required double refractionFactor,
    required bool isMetric,
    double? targetHeight,
  });

  /// Validates input parameters against range limits
  /// Returns true if all inputs are within valid ranges
  bool validateInputs({
    required double heightMeters,
    required double distanceKm,
    double? targetHeightMeters,
  }) {
    return heightMeters >= MIN_OBSERVER_HEIGHT && 
           heightMeters <= MAX_OBSERVER_HEIGHT &&
           distanceKm >= MIN_DISTANCE && 
           distanceKm <= MAX_DISTANCE &&
           (targetHeightMeters == null || 
            (targetHeightMeters >= 0 && targetHeightMeters <= MAX_TARGET_HEIGHT));
  }

  /// Converts input values to metric units for calculation
  /// Returns a tuple of (heightMeters, distanceKm, targetHeightMeters)
  (double, double, double?) convertToMetric({
    required double observerHeight,
    required double distance,
    required bool isMetric,
    double? targetHeight,
  }) {
    final double heightMeters = isMetric ? observerHeight : observerHeight * 0.3048;
    final double distanceKm = isMetric ? distance : distance * 1.60934;
    final double? targetHeightMeters = targetHeight == null 
        ? null 
        : (isMetric ? targetHeight : targetHeight * 0.3048);
    
    return (heightMeters, distanceKm, targetHeightMeters);
  }
}
