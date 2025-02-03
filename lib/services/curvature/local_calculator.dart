import 'dart:math' as math;
import '../models/calculation_result.dart';
import 'base_calculator.dart';

class LocalCurvatureCalculator extends BaseCalculator {
  @override
  Future<CalculationResult> calculate({
    required double observerHeight,
    required double distance,
    required double refractionFactor,
    required bool isMetric,
    double? targetHeight,
  }) async {
    final effectiveRadius = BaseCalculator.EARTH_RADIUS_METERS * refractionFactor;

    // Convert all inputs to metric
    final (heightMeters, distanceKm, targetHeightMeters) = convertToMetric(
      observerHeight: observerHeight,
      distance: distance,
      isMetric: isMetric,
      targetHeight: targetHeight,
    );
    final distanceMeters = distanceKm * 1000;

    // Validate inputs
    if (!validateInputs(
      heightMeters: heightMeters,
      distanceKm: distanceKm,
      targetHeightMeters: targetHeightMeters,
    )) {
      return const CalculationResult();
    }

    // Calculate using spherical geometry
    final double R = effectiveRadius;  // Effective radius including refraction
    final double C = 2 * math.pi * R;  // Earth's circumference
    
    // Calculate d1 (distance to horizon)
    final double d1 = math.sqrt(2 * heightMeters * R);
    
    // Calculate l2
    final double l2 = distanceMeters - d1;
    
    // Calculate BOX angle
    final double BOX_fraction = l2 / C;
    final double BOX_angle = 2 * math.pi * BOX_fraction;
    
    // Calculate OC and hidden height (XC)
    final double OC = R / math.cos(BOX_angle);
    final double hiddenHeight = (OC - R) / 1000;  // Convert to kilometers
    
    // Calculate total distance (d0) and visible distance (d2)
    final double d2 = R * math.sin(BOX_angle);
    final double d0 = d1 + d2;

    // Calculate geometric dip angle
    final double dipAngle = math.acos(R / (R + heightMeters)) * (180 / math.pi);

    // If no target height, return basic calculations
    if (targetHeightMeters == null) {
      return CalculationResult(
        horizonDistance: d1 / 1000,  // Convert to km
        hiddenHeight: hiddenHeight,
        totalDistance: d0 / 1000,  // Convert to km
        visibleDistance: d2 / 1000,  // Convert to km
        inputDistance: distance,  // Store original input
        h1: observerHeight,  // Store original input
        dipAngle: dipAngle,  // Add dip angle to result
      );
    }

    // Calculate visible height of target
    final visibleTargetHeight = targetHeightMeters - (hiddenHeight * 1000);  // Convert hidden height back to meters
    final clampedVisibleHeight = visibleTargetHeight < 0 ? 0 : visibleTargetHeight;

    // Calculate apparent visible height using spherical geometry
    double apparentVisibleHeight = 0;
    double perspectiveScaledHeight = 0;

    if (clampedVisibleHeight > 0) {
      // Calculate apparent height using angle from spherical geometry
      final double angle = distanceMeters / effectiveRadius;
      apparentVisibleHeight = clampedVisibleHeight * math.cos(angle);

      // Calculate perspective scaled height using pinhole camera model
      const double FOCAL_LENGTH = 1000.0;  // 1km focal length
      perspectiveScaledHeight = FOCAL_LENGTH * apparentVisibleHeight / distanceMeters;
      perspectiveScaledHeight = perspectiveScaledHeight < 0 ? 0 : perspectiveScaledHeight;
    }

    return CalculationResult(
      horizonDistance: d1 / 1000,  // Convert to km
      hiddenHeight: hiddenHeight,
      totalDistance: d0 / 1000,  // Convert to km
      visibleDistance: d2 / 1000,  // Convert to km
      visibleTargetHeight: clampedVisibleHeight / 1000,  // Convert to km
      apparentVisibleHeight: apparentVisibleHeight / 1000,  // Convert to km
      perspectiveScaledHeight: perspectiveScaledHeight / 1000,  // Convert to km
      inputDistance: distance,  // Store original input
      h1: observerHeight,  // Store original input
      dipAngle: dipAngle,  // Add dip angle to result
    );
  }
}
