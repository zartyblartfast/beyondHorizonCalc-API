# Beyond Horizon Calculator - Calculation Catalog

## Core Calculations

### 1. Earth Curvature Calculations
Located in `CurvatureCalculator` class:
- **Input Parameters**:
  - `observerHeight` (meters/feet)
  - `distance` (kilometers/miles)
  - `refractionFactor` (typically 1.07)
  - `targetHeight` (optional, meters/feet)
  - `isMetric` (boolean)

- **Calculations**:
  1. Distance to Horizon (d1)
     ```python
     d1 = sqrt(2 * height_meters * effective_radius)
     ```
  
  2. Hidden Height (XC)
     ```python
     l2 = distance_meters - d1
     BOX_fraction = l2 / circumference
     BOX_angle = 2 * pi * BOX_fraction
     OC = effective_radius / cos(BOX_angle)
     hidden_height = (OC - effective_radius) / 1000  # Convert to kilometers
     ```
  
  3. Total Distance (d0) and Visible Distance (d2)
     ```python
     d2 = effective_radius * sin(BOX_angle)
     d0 = d1 + d2
     ```
  
  4. Target Visibility Calculations (when target height provided)
     ```python
     visible_height = max(0, target_height - hidden_height)
     perspective_scale = 1 - (distance_meters / (2 * EARTH_RADIUS))
     apparent_visible_height = visible_height * perspective_scale
     perspective_scaled_height = target_height * perspective_scale
     ```

### 2. Unit Conversions
- Metric to Imperial:
  - Meters to Feet: × 3.28084
  - Kilometers to Miles: × 0.621371
- Imperial to Metric:
  - Feet to Meters: × 0.3048
  - Miles to Kilometers: × 1.60934

### 3. Constants
```python
EARTH_RADIUS_METERS = 6371000
FOCAL_LENGTH = 1000.0  # 1km focal length for perspective calculations
```

## API Interface

### Endpoint
POST `/api/calculate`

### Request Format
```json
{
  "observerHeight": number,  // Height of observer
  "distance": number,        // Distance to target
  "refractionFactor": number, // Default: 1.07
  "targetHeight": number,    // Optional
  "isMetric": boolean       // true for metric, false for imperial
}
```

### Response Format
```json
{
  "hiddenHeight": number,    // Height hidden by Earth's curvature
  "horizonDistance": number, // Distance to horizon
  "totalDistance": number,   // Total distance to target
  "dipAngle": number,       // Geometric dip angle
  "isMetric": boolean,      // Units of returned values
  
  // Only present if targetHeight was provided
  "visibleTargetHeight": number,      // Visible portion of target
  "apparentVisibleHeight": number,    // Visible height adjusted for perspective
  "perspectiveScaledHeight": number,  // Total height adjusted for perspective
  "targetVisible": boolean            // Whether target is visible
}
```

### Validation Rules
1. Observer Height
   - Minimum: 2.0 meters (6.56 feet)
   - Maximum: 9000.0 meters (29527.56 feet)
   - Error: "Observer height must be at least X meters" or "Observer height must be less than X meters"

2. Distance
   - Minimum: 5.0 kilometers (3.11 miles)
   - Maximum: 600.0 kilometers (372.82 miles)
   - Error: "Distance must be at least X km" or "Distance must be less than X km"

3. Target Height
   - Minimum: 0.0 meters (0.0 feet)
   - Maximum: 9000.0 meters (29527.56 feet)
   - Error: "Target height must be at least 0 meters" or "Target height must be less than X meters"

4. Refraction Factor
   - Must be positive
   - Typical value: 1.07
   - Error: "Refraction factor must be positive"

### Error Response Format
```json
{
  "error": string  // Description of the validation error
}
```

## Implementation Status (2025-02-02)
 Core calculation port  
 Unit conversion functions  
 Input validation  
 API endpoint structure  
 Response formatting  
 Test suite  
 Geometric dip calculation  

### Validation Testing
The API has been thoroughly tested with the following test categories:

1. Basic Calculations
   - Minimum valid observer height
   - Standard observation scenario
   - Imperial unit conversion

2. Input Validation
   - Observer height limits
   - Distance limits
   - Target height validation
   - Refraction factor validation

3. Target Height Calculations
   - Basic target visibility
   - Target height validation

### Next Steps
1. Deploy to Azure Functions
2. Set up CI/CD pipeline
3. Add API documentation with Swagger/OpenAPI
4. Implement monitoring and logging
5. Add rate limiting and security measures
