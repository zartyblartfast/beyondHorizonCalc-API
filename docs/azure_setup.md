# Azure Functions Setup Guide

## Initial Setup (2025-02-02)

### Prerequisites
- Active Microsoft Azure Account
- Visual Studio Code
- Windows OS
- Python 3.9+ (required for Azure Functions)
- Dart SDK (for running tests)

### Project Structure

The project follows Azure Functions best practices with a clear separation of concerns:

```
BeyondHorizonCalc-API/
├── api/                    # Legacy API code (deprecated)
├── calculate/              # Main Function App
│   ├── __init__.py        # HTTP trigger and request handling
│   ├── calculations.py    # Core calculation logic
│   ├── constants.py       # Configuration constants
│   ├── function.json      # Function binding configuration
│   └── requirements.txt   # Python dependencies
├── docs/                  # Documentation
├── host.json             # Host configuration
├── local.settings.json   # Local settings and connection strings
└── requirements.txt      # Project-level dependencies
```

#### Directory Roles
1. `/calculate` (Active)
   - Primary Function App directory
   - Contains all calculation logic and API endpoints
   - Follows Azure Functions v2 programming model
   - Uses in-process function execution

2. `/api` (Deprecated)
   - Legacy implementation using older Azure Functions model
   - Kept for reference but not actively used
   - Will be removed in future updates

#### Best Practices Implementation
1. **Code Organization**
   - Clear separation between HTTP handling (`__init__.py`) and business logic (`calculations.py`)
   - Constants isolated in `constants.py` for easy configuration
   - Each function in its own directory with its configuration

2. **Configuration Management**
   - Function-specific settings in `function.json`
   - Host-level settings in `host.json`
   - Environment variables in `local.settings.json`

3. **Dependency Management**
   - Function-level dependencies in `/calculate/requirements.txt`
   - Project-level dependencies in root `requirements.txt`
   - Virtual environment isolation

4. **Documentation**
   - API documentation in `/docs`
   - Inline code documentation
   - Setup and configuration guides

### 1. VS Code Extension Installation
1. Open VS Code Extensions (Ctrl+Shift+X)
2. Search for "Azure Functions"
3. Install the official Microsoft extension:
   - Name: Azure Functions
   - Publisher: Microsoft
   - ID: ms-azuretools.vscode-azurefunctions
   - Description: Azure Functions extension for VS Code that helps create, debug, manage, and deploy serverless apps

### 2. Azure Functions Core Tools Installation
1. Open PowerShell as Administrator
2. Install using Windows Package Manager (winget):
   ```powershell
   winget install Microsoft.Azure.FunctionsCoreTools
   ```
3. Version installed: 4.0.6821

### 3. Azure CLI Installation
1. Open PowerShell as Administrator
2. Install using Windows Package Manager (winget):
   ```powershell
   winget install Microsoft.AzureCLI
   ```

### Next Steps
1. Restart VS Code for tools initialization
2. Sign in to Azure through VS Code:
   - Click Azure icon in Activity Bar
   - Click "Sign in to Azure"
   - Complete authentication process

### Python Development Setup
1. Install Python 3.9+ (required for Azure Functions)
2. Install Python extension for VS Code
3. Create Python-based Azure Functions project:
   ```bash
   func init MyFunctionProj --python
   cd MyFunctionProj
   func new --name HttpExample --template "HTTP trigger"
   ```
4. Set up virtual environment:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate
   pip install -r requirements.txt
   ```

### Required Python Packages
- azure-functions
- tweepy (for Twitter bot integration)
- numpy (for calculations)
- python-dotenv (for environment variables)

### Important Notes
- Using Python for better integration with:
  - Twitter API (via tweepy)
  - AI/ML libraries
  - Mathematical computations
- Local testing environment crucial before deployment
- All development will be done on 'dev1' branch

## Progress Update (2025-02-02 20:20)

### Completed Steps
1. ✅ VS Code restarted after tools installation
2. ✅ Azure Functions project initialized
3. ✅ Created `calculate` HTTP trigger endpoint
4. ✅ Python virtual environment set up
5. ✅ Core dependencies installed:
   - azure-functions

### Next Steps
1. Port calculation logic from Flutter:
   - Review existing Flutter calculation code
   - Convert to Python implementation
   - Implement input validation
   - Structure JSON response format

2. Test local development:
   - Test endpoint with sample requests
   - Verify calculation accuracy
   - Document API interface

3. Twitter Bot Integration:
   - Install tweepy and python-dotenv
   - Create webhook endpoint
   - Implement bot logic

## Project Status (2025-02-02)

### Completed
1. Project Structure
   - Azure Functions project initialized
   - Python virtual environment set up
   - Core dependencies installed

2. API Implementation
   - Single consolidated `/api/calculate` endpoint
   - Input validation matching Flutter app limits
   - Unit conversion support (metric/imperial)
   - All calculations ported including geometric dip angle
   - Error handling and validation messages

3. Configuration
   - `host.json` configured
   - Python runtime selected
   - Port configuration (7072)

### Current Issues
1. Integration Testing
   - Need to update test suite to use regular Dart test package instead of Flutter test
   - Test runner encountering Flutter UI dependency issues
   - API validation tests need to be implemented

### Next Steps
1. Testing Setup
   - [ ] Convert integration tests from Flutter to regular Dart tests
   - [ ] Add test cases for input validation
   - [ ] Add test cases for geometric dip angle
   - [ ] Verify unit conversions

2. API Testing
   - [ ] Test all error conditions
   - [ ] Verify response format matches documentation
   - [ ] Compare results with Flutter app calculations

3. Documentation
   - [ ] Add API usage examples
   - [ ] Document error responses
   - [ ] Add deployment instructions

### Current Project Structure
```
api/
├── .venv/                 # Python virtual environment
├── calculate/            # Calculation endpoint
├── function_app.py       # Main application file
├── host.json            # Host configuration
├── local.settings.json  # Local settings
└── requirements.txt     # Python dependencies
```

### Detailed Setup Commands Used
```bash
# 1. Project Initialization
cd c:\Users\clive\VSC\BeyondHorizonCalc-API
func init --worker-runtime python --language python

# 2. Virtual Environment Setup
cd api
python -m venv .venv
.venv\Scripts\activate

# 3. Dependencies Installation
pip install azure-functions

# 4. Create Calculation Endpoint
func new --name calculate --template "HTTP trigger"
# Selected authentication level: Function
```

### Configuration Files
1. `host.json` - Default configuration:
```json
{
    "version": "2.0",
    "logging": {
        "applicationInsights": {
            "samplingSettings": {
                "isEnabled": true,
                "excludedTypes": "Request"
            }
        }
    }
}
```

2. `local.settings.json` template:
```json
{
    "IsEncrypted": false,
    "Values": {
        "FUNCTIONS_WORKER_RUNTIME": "python",
        "AzureWebJobsStorage": ""
    }
}
```

### Local Development
1. Start local server:
```bash
func start
```
2. Default endpoints:
   - Local URL: http://localhost:7071
   - Calculate endpoint: http://localhost:7071/api/calculate

### Local Development and Testing

### Running the API Locally
1. Navigate to the API directory:
   ```bash
   cd BeyondHorizonCalc-API
   ```

2. Start the Functions host:
   ```bash
   func start --verbose
   ```
   - Default port is 7071
   - Use `--port <number>` to specify a different port if needed
   - Use `--verbose` flag for detailed logging

### Running Integration Tests
1. Navigate to the test project:
   ```bash
   cd BeyondHorizonCalc
   ```

2. Update the API port in `test/integration/api_test.dart` if needed:
   ```dart
   const String apiBaseUrl = 'http://localhost:<port>/api';
   ```

3. Run the tests:
   ```bash
   dart test test/integration/api_test.dart --chain-stack-traces
   ```

### Test Categories
The test suite includes:
1. Basic Calculations
   - Minimum valid observer height
   - Standard observation scenario
   - Imperial unit conversion

2. Input Validation
   - Observer height limits (2m-9000m)
   - Distance limits (5km-600km)
   - Target height validation
   - Refraction factor validation

3. Target Height Calculations
   - Basic target visibility
   - Target height validation

### Troubleshooting
1. Port Conflicts
   - If the default port is in use, try a different port using `--port`
   - Common ports used: 7071-7090

2. Common Issues
   - Ensure Python virtual environment is activated
   - Verify all dependencies are installed
   - Check function.json points to correct script file
   - Ensure local.settings.json exists with proper configuration

### Troubleshooting Tips
1. If virtual environment is not activating:
   ```bash
   # PowerShell may need execution policy adjustment
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
2. If dependencies are not found:
   ```bash
   # Reinstall dependencies
   pip install -r requirements.txt
   ```
3. Common port conflicts:
   - Check if port 7071 is in use
   - Can be changed in local.settings.json:
     ```json
     {
         "Values": {
             "FUNCTIONS_HTTPWORKER_PORT": "7072"
         }
     }
     ```

### Related Documentation
- [Azure Functions Core Tools Documentation](https://docs.microsoft.com/azure/azure-functions/functions-run-local)
- [VS Code Azure Functions Extension Guide](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions)
- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
