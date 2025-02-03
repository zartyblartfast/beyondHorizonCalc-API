# Beyond Horizon Calculator API Setup Guide

## Overview
This document details the setup and configuration of the Beyond Horizon Calculator API, an Azure Functions-based service that calculates Earth curvature effects on visibility. The API supports both metric and imperial units and provides comprehensive calculations including horizon distance, hidden height, and geometric dip angle.

## Prerequisites
- Active Microsoft Azure Account
- Visual Studio Code
- Windows OS
- Python 3.9+ (required for Azure Functions)
- Dart SDK (for running tests)
- Azure Functions Core Tools
- Git

## Project Structure
```
BeyondHorizonCalc-API/
├── calculate/                 # Main Function App
│   ├── __init__.py           # HTTP trigger and request handling
│   ├── calculations.py       # Core calculation logic
│   ├── constants.py          # Configuration constants
│   ├── function.json         # Function binding configuration
│   └── local.settings.json   # Function-specific settings
├── tests/                    # Python unit tests
│   ├── __init__.py
│   ├── test_calculations.py  # Core calculation tests
│   └── test_api.py          # API endpoint tests
├── test/                     # Dart integration tests
├── docs/                     # Documentation
├── host.json                 # Host configuration
├── local.settings.json       # Local settings and connection strings
└── requirements.txt          # Project-level dependencies
```

## Initial Setup

### 1. Environment Setup
1. Install Python 3.9+:
   ```powershell
   winget install Python.Python.3.9
   ```

2. Install Azure Functions Core Tools:
   ```powershell
   winget install Microsoft.Azure.FunctionsCoreTools
   ```

3. Install VS Code Extensions:
   - Azure Functions (ms-azuretools.vscode-azurefunctions)
   - Python (ms-python.python)
   - Dart (Dart-Code.dart-code)

### 2. Project Setup
1. Clone the repository:
   ```powershell
   git clone https://github.com/zartyblartfast/beyondHorizonCalc-API.git
   cd beyondHorizonCalc-API
   ```

2. Create Python virtual environment:
   ```powershell
   python -m venv .venv
   .venv\Scripts\activate
   ```

3. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   ```

4. Configure local settings:
   - Copy `.env.template` to `.env`
   - Copy template settings to `local.settings.json`:
   ```json
   {
       "IsEncrypted": false,
       "Values": {
           "FUNCTIONS_WORKER_RUNTIME": "python",
           "AzureWebJobsStorage": "UseDevelopmentStorage=true"
       }
   }
   ```

## API Configuration

### 1. Core Calculation Setup
The API is built around the `CurvatureCalculator` class in `calculate/calculations.py`, which handles:
- Horizon distance calculation
- Hidden height calculation
- Geometric dip angle calculation
- Target visibility calculation
- Unit conversion (metric/imperial)

### 2. Input Validation
Constants in `calculate/constants.py` define the valid ranges:
```python
MIN_OBSERVER_HEIGHT = 2.0    # meters
MAX_OBSERVER_HEIGHT = 9000.0 # meters
MIN_DISTANCE = 5.0          # kilometers
MAX_DISTANCE = 600.0        # kilometers
MAX_TARGET_HEIGHT = 9000.0  # meters
```

### 3. API Endpoint
The `/calculate` endpoint accepts JSON requests:
```json
{
    "observerHeight": 2.0,      // meters (required)
    "distance": 10.0,           // kilometers (required)
    "targetHeight": 100.0,      // meters (optional)
    "refractionFactor": 1.07,   // optional, defaults to 1.07
    "isMetric": true           // optional, defaults to true
}
```

Response format:
```json
{
    "hiddenHeight": 7.335,           // meters
    "horizonDistance": 5.222,        // km if metric, miles if not
    "totalDistance": 10.000,         // km if metric, miles if not
    "dipAngle": 0.0454,             // degrees
    "isMetric": true,               // units flag
    "visibleTargetHeight": 92.665,   // meters (if target_height provided)
    "apparentVisibleHeight": 92.593, // meters (if target_height provided)
    "perspectiveScaledHeight": 99.922, // meters (if target_height provided)
    "targetVisible": true            // boolean (if target_height provided)
}
```

## Testing Setup

### 1. Python Tests
Located in `/tests/`, covering core calculations and API functionality:

1. Run tests:
   ```powershell
   python -m unittest tests/test_calculations.py -v
   ```

2. Test coverage:
   - Horizon distance calculation
   - Hidden height calculation
   - Dip angle calculation
   - Unit conversion
   - Input validation
   - Complete calculation output

Example test output:
```
Horizon Distance Test Results:
Expected horizon distance: 5.222 km
Actual horizon distance:   5.222 km

Hidden Height Test Results:
Total distance: 10.000 km
Hidden height: 7.335 m

Dip Angle Test Results:
Observer height: 2.0 m
Expected dip angle: 0.0454°
Actual dip angle:   0.0454°
```

### 2. Dart Integration Tests
Located in `/test/`, providing end-to-end testing with the Flutter app:

1. Run tests:
   ```powershell
   dart test test/services/curvature_calculator_test.dart -r expanded
   ```

2. Test coverage:
   - API endpoint integration
   - JSON serialization/deserialization
   - Error handling
   - Unit conversion consistency

## Deployment

### 1. Local Development
1. Start the Function App:
   ```powershell
   func start
   ```
2. API will be available at: `http://localhost:7071/api/calculate`

### 2. Azure Deployment
1. Create Azure Function App:
   ```powershell
   az functionapp create --name BeyondHorizonCalc --storage-account <account> --consumption-plan-location westus --runtime python
   ```

2. Deploy using VS Code:
   - Click Azure icon
   - Right-click subscription
   - Select "Deploy to Function App"
   - Choose BeyondHorizonCalc

## Version Control
1. Main development branch: `dev1`
2. Files ignored in git:
   - `local.settings.json`
   - `.env`
   - Python cache files
   - Test output files
   - Virtual environment directories

## Troubleshooting
1. If tests fail:
   - Verify Python virtual environment is activated
   - Check input validation ranges
   - Ensure correct unit conversion

2. If API returns errors:
   - Check request JSON format
   - Verify input values are within allowed ranges
   - Check local.settings.json configuration

## References
- [Azure Functions Python Guide](https://docs.microsoft.com/azure/azure-functions/functions-reference-python)
- [Earth Curvature Calculator Documentation](https://beyondhorizons.readthedocs.io/)
- [Testing Python Azure Functions](https://docs.microsoft.com/azure/azure-functions/functions-reference-python#unit-testing)
