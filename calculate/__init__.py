import azure.functions as func
import logging
import json
from typing import Optional, Tuple
from .calculations import CurvatureCalculator
from .constants import RangeLimits

def convert_to_metric(observer_height: float, distance: float, is_metric: bool, target_height: Optional[float] = None) -> Tuple[float, float, Optional[float]]:
    """Convert input values to metric units if they aren't already."""
    if not is_metric:
        # Convert feet to meters
        observer_height = observer_height * 0.3048
        if target_height is not None:
            target_height = target_height * 0.3048
        # Convert miles to kilometers
        distance = distance * 1.60934
    return observer_height, distance, target_height

def validate_metric_inputs(height_meters: float, distance_km: float, target_height_meters: Optional[float] = None) -> Optional[func.HttpResponse]:
    """Validate inputs that are already in metric units. Returns error response if invalid, None if valid."""
    if height_meters < RangeLimits.MIN_OBSERVER_HEIGHT:
        return func.HttpResponse(
            json.dumps({
                'error': f'Observer height must be at least {RangeLimits.MIN_OBSERVER_HEIGHT} meters'
            }),
            status_code=400
        )
        
    if height_meters > RangeLimits.MAX_OBSERVER_HEIGHT:
        return func.HttpResponse(
            json.dumps({
                'error': f'Observer height must be less than {RangeLimits.MAX_OBSERVER_HEIGHT} meters'
            }),
            status_code=400
        )
        
    if distance_km < RangeLimits.MIN_DISTANCE:
        return func.HttpResponse(
            json.dumps({
                'error': f'Distance must be at least {RangeLimits.MIN_DISTANCE} km'
            }),
            status_code=400
        )
        
    if distance_km > RangeLimits.MAX_DISTANCE:
        return func.HttpResponse(
            json.dumps({
                'error': f'Distance must be less than {RangeLimits.MAX_DISTANCE} km'
            }),
            status_code=400
        )
        
    if target_height_meters is not None:
        if target_height_meters < 0:
            return func.HttpResponse(
                json.dumps({
                    'error': 'Target height must be at least 0 meters'
                }),
                status_code=400
            )
            
        if target_height_meters > RangeLimits.MAX_TARGET_HEIGHT:
            return func.HttpResponse(
                json.dumps({
                    'error': f'Target height must be less than {RangeLimits.MAX_TARGET_HEIGHT} meters'
                }),
                status_code=400
            )
    
    return None

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
        logging.info(f'Request body: {req_body}')
        
        observer_height = float(req_body.get('observerHeight', 0))
        distance = float(req_body.get('distance', 0))
        refraction_factor = float(req_body.get('refractionFactor', 1.07))
        is_metric = bool(req_body.get('isMetric', True))
        target_height: Optional[float] = req_body.get('targetHeight')
        
        if target_height is not None:
            target_height = float(target_height)

        # Log original values
        logging.info(f'Original values - Height: {observer_height} {"m" if is_metric else "ft"}, '
                    f'Distance: {distance} {"km" if is_metric else "mi"}, '
                    f'Target Height: {target_height} {"m" if is_metric else "ft"}')

        # Convert to metric first (matching local calculator pattern)
        height_meters, distance_km, target_height_meters = convert_to_metric(
            observer_height, distance, is_metric, target_height
        )

        # Log converted values
        logging.info(f'Converted to metric - Height: {height_meters}m, '
                    f'Distance: {distance_km}km, '
                    f'Target Height: {target_height_meters}m')

        # Validate the converted metric values
        validation_error = validate_metric_inputs(height_meters, distance_km, target_height_meters)
        if validation_error:
            return validation_error

        if refraction_factor <= 0:
            return func.HttpResponse(
                json.dumps({
                    'error': 'Refraction factor must be positive'
                }),
                status_code=400
            )

        calculator = CurvatureCalculator(
            observer_height=height_meters,  # Pass converted values
            distance=distance_km,
            refraction_factor=refraction_factor,
            is_metric=True,  # Values are now in metric
            target_height=target_height_meters
        )
        
        result = calculator.calculate()
        return func.HttpResponse(
            json.dumps(result),
            mimetype='application/json'
        )
            
    except ValueError as e:
        return func.HttpResponse(
            json.dumps({
                'error': str(e)
            }),
            status_code=400
        )
    except Exception as e:
        logging.error(f'Error processing request: {e}')
        return func.HttpResponse(
            json.dumps({
                'error': f'Internal server error: {str(e)}'
            }),
            status_code=500
        )
