# Beyond Horizon Calculator - API Integration Test Plan

## Overview
This repository serves as a test harness for the Beyond Horizon Calculator API, containing a modified version of the Flutter app that can use both local and API calculations. This allows us to:
1. Verify API functionality matches local calculations exactly
2. Test API integration patterns for external consumers
3. Ensure API completeness for Twitter Bot and AI Agent use cases
4. Document integration patterns and best practices

## Test Harness Architecture

### Directory Structure
```
lib/
├── services/
│   ├── curvature/
│   │   ├── curvature_calculator.dart         # Original local calculator
│   │   ├── api_calculator.dart               # API client implementation
│   │   └── calculator_test_harness.dart      # Test harness utilities
│   └── models/
│       └── calculation_result.dart           # Calculation result model
```

### Test Harness Features
1. Side-by-Side Calculation Comparison
   - Run calculations through both local and API methods
   - Compare results for exact matching
   - Log any discrepancies
   - Measure and log API response times

2. API Integration Testing
   - Test all API endpoints
   - Verify error handling
   - Test edge cases
   - Validate response formats

3. External Consumer Simulation
   - Simulate Twitter Bot usage patterns
   - Test AI Agent interaction scenarios
   - Verify rate limiting behavior
   - Test error recovery patterns

## Implementation Plan

### Phase 1: Test Harness Setup
1. Add API Client
   - Implement API calls
   - Match request/response formats
   - Add logging
   - Include timing measurements

2. Add Comparison Logic
   - Run parallel calculations
   - Compare results
   - Log differences
   - Track API performance

3. Add Test Utilities
   - Result comparison tools
   - Logging utilities
   - Test data generators
   - Performance tracking

### Phase 2: Integration Testing
1. Basic Calculations
   - Test all calculation types
   - Verify unit conversions
   - Test input validation
   - Compare precision/rounding

2. Error Handling
   - Test invalid inputs
   - Verify error messages
   - Test network errors
   - Validate error formats

3. Performance Testing
   - Measure response times
   - Test concurrent requests
   - Verify rate limiting
   - Document performance characteristics

### Phase 3: External Consumer Testing
1. Twitter Bot Scenarios
   - Test tweet-length responses
   - Verify formatting
   - Test rate limits
   - Validate error handling

2. AI Agent Integration
   - Test structured responses
   - Verify data formats
   - Test batch calculations
   - Validate complex queries

## Test Cases

### Calculation Verification
```dart
void testCalculation({
  required double observerHeight,
  required double distance,
  double? targetHeight,
  bool isMetric = true,
}) {
  // Run local calculation
  final localResult = CurvatureCalculator.calculate(...);
  
  // Run API calculation
  final apiResult = await ApiCalculator.calculate(...);
  
  // Compare results
  compareResults(localResult, apiResult);
  
  // Log performance
  logApiPerformance(apiResult.responseTime);
}
```

### Result Comparison
```dart
void compareResults(CalculationResult local, CalculationResult api) {
  assert(local.hiddenHeight == api.hiddenHeight);
  assert(local.horizonDistance == api.horizonDistance);
  assert(local.dipAngle == api.dipAngle);
  // ... more comparisons
}
```

## Documentation Generation

### API Consumer Documentation
- Generate OpenAPI specification
- Create integration examples
- Document error handling
- Provide rate limiting details

### Performance Documentation
- Document response times
- Provide concurrent request limits
- Detail rate limiting rules
- List resource constraints

## Success Criteria
1. Functional Completeness
   - All calculations match local results
   - All error cases handled correctly
   - All external consumer scenarios supported

2. Documentation Quality
   - Complete API documentation
   - Clear integration examples
   - Detailed error handling guide
   - Performance characteristics documented

3. Test Coverage
   - All calculation types tested
   - All error conditions verified
   - All consumer scenarios validated
   - Performance metrics collected

## Next Steps
1. Implement API client
2. Add comparison logging
3. Create test scenarios
4. Document findings
5. Validate external consumer use cases

## Future Considerations
1. Additional API Features
   - Batch calculations
   - Extended result formats
   - Additional calculation types
   - Performance optimizations

2. Integration Patterns
   - OAuth authentication
   - API key management
   - Rate limiting strategies
   - Caching recommendations
