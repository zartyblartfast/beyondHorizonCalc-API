import '../models/calculation_result.dart';
import 'base_calculator.dart';
import 'local_calculator.dart';
import 'api_calculator.dart';

/// Factory class for creating the appropriate calculator implementation
class CurvatureCalculator {
  static final LocalCurvatureCalculator _localCalculator = LocalCurvatureCalculator();
  static final ApiCurvatureCalculator _apiCalculator = ApiCurvatureCalculator();

  /// Gets the appropriate calculator based on useApi flag
  static BaseCalculator getCalculator({bool useApi = false}) {
    return useApi ? _apiCalculator : _localCalculator;
  }

  /// Convenience method to perform calculations using the appropriate calculator
  static Future<CalculationResult> calculate({
    required double observerHeight,
    required double distance,
    required double refractionFactor,
    required bool isMetric,
    double? targetHeight,
    bool useApi = false,
  }) {
    final calculator = getCalculator(useApi: useApi);
    return calculator.calculate(
      observerHeight: observerHeight,
      distance: distance,
      refractionFactor: refractionFactor,
      isMetric: isMetric,
      targetHeight: targetHeight,
    );
  }
}
