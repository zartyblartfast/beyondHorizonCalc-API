# Beyond Horizon Calculator - API Integration Plan

## Overview
This repository contains a version of the Beyond Horizon Calculator app that integrates both local and API-based calculations. This implementation:
1. Allows switching between local and API calculations via configuration
2. Provides clear UI indication of calculation source
3. Serves as a testing ground for API functionality
4. Maintains calculation consistency between methods

## Architecture

### Directory Structure
```
lib/
├── services/
│   ├── curvature/
│   │   ├── curvature_calculator.dart         # Base calculator interface
│   │   ├── local_calculator.dart             # Local implementation
│   │   └── api_calculator.dart               # API implementation
│   └── models/
│       └── calculation_result.dart           # Calculation result model
```

### Configuration System
```dart
enum CalculationMode {
  local,    // Use local calculations
  api       // Use API calculations
}

class CalculationConfig {
  static CalculationMode mode = CalculationMode.local;
}
```

### Calculator Interface
```dart
abstract class BaseCalculator {
  Future<CalculationResult> calculate({
    required double observerHeight,
    required double distance,
    required double refractionFactor,
    required bool isMetric,
    double? targetHeight,
  });
}
```

## Implementation Plan

### Phase 1: Configuration Setup
1. Add Configuration System
   - Create CalculationMode enum
   - Implement CalculationConfig service
   - Add persistence for settings

2. Update UI
   - Add settings toggle for calculation source
   - Add calculation source indicator below results
   - Update results display for API status

### Phase 2: API Integration
1. API Calculator Implementation
   - Create BaseCalculator interface
   - Implement ApiCalculator class
   - Add error handling
   - Handle network timeouts

2. Error Handling
   - Show appropriate error messages
   - Handle network errors gracefully
   - Validate API responses

### Phase 3: Testing
1. Calculation Verification
   - Test both calculation methods
   - Verify results match
   - Test error scenarios
   - Validate configuration

2. Integration Testing
   - Test network scenarios
   - Verify error handling
   - Test configuration persistence

## API Integration

### Quick Start Guide

#### Prerequisites
1. Python 3.8 or higher
2. Node.js and npm
3. Flutter SDK
4. Azure Functions Core Tools v4

#### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/zartyblartfast/beyondHorizonCalc-API.git
   cd beyondHorizonCalc-API
   ```

2. **Set Up Python Environment**
   ```bash
   python -m venv .venv
   .venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Configure Local Settings**
   - Copy `local.settings.example.json` to `local.settings.json`
   - Update settings if needed (default values work for local development)

4. **Start the API Server**
   ```bash
   func start
   ```
   The API will be available at `http://localhost:7071/api/calculate`

5. **Run the Flutter App**
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

### API Integration Status

#### Completed Features
1. **API Endpoint**
   - Endpoint: `/api/calculate`
   - Handles all curvature calculations
   - Supports both metric and imperial units
   - Input validation matches Flutter app limits

2. **UI Integration**
   - Toggle switch between local and API calculations
   - Clear indication of calculation source
   - Error handling with user-friendly messages
   - Option to switch back to local calculations on API errors

3. **Input Validation**
   - Observer height: 2-9000m
   - Distance: 5-600km
   - Target height: up to 9000m
   - Default refraction factor: 1.07

#### Current Issues

1. **UI Layout Bug** (Unresolved)
   - When switching to API calculations, a grey rectangle appears and replaces the toggle button
   - Issue occurs after successful API calls (not during error states)
   - Attempted fixes:
     - Adjusted layout constraints and padding
     - Modified error handling in ResultsDisplay
     - Tried synchronizing field names between API and Flutter app
     - Issue persists despite these changes
   - Root cause investigation ongoing

2. **API Response Format**
   - API returns camelCase fields (e.g., 'hiddenHeight')
   - Flutter app has been updated to match this format
   - Field mapping:
     ```
     horizonDistance -> distance to horizon
     hiddenHeight -> hidden height (h2)
     visibleTargetHeight -> visible height (h3)
     apparentVisibleHeight -> apparent visible height
     perspectiveScaledHeight -> perspective scaled height
     ```

## Code Changes History

### Key File Modifications

1. **results_display.dart**
   ```dart
   // Toggle button implementation in success state
   Row(
     mainAxisAlignment: MainAxisAlignment.spaceBetween,
     children: [
       Text('Using ${useApiCalculations ? "API" : "local"} calculations'),
       Switch(
         value: useApiCalculations, 
         onChanged: onCalculationModeChanged,
       ),
     ],
   )

   // Error state button
   ElevatedButton(
     onPressed: () => onCalculationModeChanged?.call(false),
     child: const Text('Switch to Local Calculations'),
   )
   ```

2. **api_calculator.dart**
   ```dart
   // API response parsing
   return CalculationResult(
     horizonDistance: data['horizonDistance']?.toDouble(),
     hiddenHeight: data['hiddenHeight']?.toDouble(),
     visibleTargetHeight: data['visibleTargetHeight']?.toDouble(),
     apparentVisibleHeight: data['apparentVisibleHeight']?.toDouble(),
     perspectiveScaledHeight: data['perspectiveScaledHeight']?.toDouble(),
   );
   ```

3. **calculations.py (API)**
   ```python
   # API response format
   result = {
       'hiddenHeight': hidden_height,
       'horizonDistance': horizon_distance_km,
       'totalDistance': original_distance,
       'dipAngle': dip_angle,
       'isMetric': is_metric
   }
   ```

### Recent Changes and Issues

1. **Field Name Synchronization**
   - Initially used snake_case in API (`hidden_height`)
   - Changed to camelCase (`hiddenHeight`) to match existing code
   - Updated Flutter app to expect camelCase fields
   - Issue persists despite field name changes

2. **UI Layout Investigation**
   - Grey rectangle appears only after successful API response
   - Toggle button disappears when grey rectangle appears
   - Error state UI works correctly without grey rectangle
   - Layout issue seems tied to successful response handling

3. **Next Investigation Steps**
   - Review widget tree when grey rectangle appears
   - Check state management in ResultsDisplay
   - Verify response parsing in success case
   - Compare layouts between error and success states

## UI Implementation

### Settings Toggle
```dart
Switch(
  value: CalculationConfig.mode == CalculationMode.api,
  onChanged: (value) {
    setState(() {
      CalculationConfig.mode = value 
          ? CalculationMode.api 
          : CalculationMode.local;
    });
  },
)
```

### Results Display
```dart
Column(
  children: [
    // Existing results display
    Text(
      'Using ${CalculationConfig.mode == CalculationMode.api 
          ? "API" 
          : "Local"} calculations',
      style: Theme.of(context).textTheme.caption,
    ),
  ],
)
```

## Error Handling
1. Network Errors
   - Show error message
   - Allow retry
   - Clear error on new calculation

2. API Errors
   - Display validation errors
   - Show server errors
   - Handle timeouts

## Testing Requirements
1. Functional Testing
   - Verify both calculation methods
   - Test configuration persistence
   - Validate error handling

2. Integration Testing
   - Test network scenarios
   - Verify API responses
   - Test configuration changes

## Success Criteria
1. Functionality
   - Both calculation methods work correctly
   - Configuration persists between sessions
   - Error handling works as expected

2. User Experience
   - Clear indication of calculation source
   - Smooth switching between methods
   - Appropriate error messages

## Next Steps
1. Implement configuration system
2. Create API calculator
3. Add UI elements
4. Implement error handling
5. Add tests

## Future Considerations
1. API Documentation
   - Document endpoint
   - Provide integration examples
   - Document error handling

2. External Consumers
   - Twitter Bot integration
   - AI Agent integration
   - Performance monitoring

## Troubleshooting

1. **Common Issues**
   - If API is unreachable, check if `func start` is running
   - Verify CORS settings in `local.settings.json`
   - Check browser console for error messages
   - Ensure all dependencies are installed

2. **Debug Steps**
   - Enable verbose logging in Flutter app
   - Monitor API responses in browser network tab
   - Check Azure Functions logs
   - Verify API endpoint configuration
