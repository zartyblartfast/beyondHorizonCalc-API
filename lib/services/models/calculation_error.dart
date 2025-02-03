/// Represents an error that occurred during calculation
class CalculationError {
  /// The type of error that occurred
  final CalculationErrorType type;

  /// A user-friendly message describing the error
  final String message;

  /// Optional technical details about the error
  final String? details;

  const CalculationError({
    required this.type,
    required this.message,
    this.details,
  });

  /// Creates an error for when the API is unreachable
  factory CalculationError.apiUnreachable([String? details]) {
    return CalculationError(
      type: CalculationErrorType.apiUnreachable,
      message: 'Unable to reach the calculation server. Please try again or switch to local calculations.',
      details: details,
    );
  }

  /// Creates an error for when the API returns an error response
  factory CalculationError.apiError(String message, [String? details]) {
    return CalculationError(
      type: CalculationErrorType.apiError,
      message: message,
      details: details,
    );
  }

  /// Creates an error for invalid input values
  factory CalculationError.invalidInput(String message) {
    return CalculationError(
      type: CalculationErrorType.invalidInput,
      message: message,
    );
  }

  /// Converts the error to a map representation
  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'message': message,
      if (details != null) 'details': details,
    };
  }

  /// Creates an error from a map representation
  factory CalculationError.fromMap(Map<String, dynamic> map) {
    return CalculationError(
      type: CalculationErrorType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => CalculationErrorType.apiError,
      ),
      message: map['message'] as String,
      details: map['details'] as String?,
    );
  }
}

/// Types of calculation errors that can occur
enum CalculationErrorType {
  /// The API server could not be reached
  apiUnreachable,

  /// The API returned an error response
  apiError,

  /// The input values were invalid
  invalidInput,
}
