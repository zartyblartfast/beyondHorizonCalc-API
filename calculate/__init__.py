import azure.functions as func
import logging
import json
from typing import Optional
from .calculations import CurvatureCalculator
from .constants import RangeLimits

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

        # Input validation
        if observer_height < RangeLimits.MIN_OBSERVER_HEIGHT:
            return func.HttpResponse(
                json.dumps({
                    'error': f'Observer height must be at least {RangeLimits.MIN_OBSERVER_HEIGHT} meters'
                }),
                status_code=400
            )
            
        if observer_height > RangeLimits.MAX_OBSERVER_HEIGHT:
            return func.HttpResponse(
                json.dumps({
                    'error': f'Observer height must be less than {RangeLimits.MAX_OBSERVER_HEIGHT} meters'
                }),
                status_code=400
            )
            
        if distance < RangeLimits.MIN_DISTANCE:
            return func.HttpResponse(
                json.dumps({
                    'error': f'Distance must be at least {RangeLimits.MIN_DISTANCE} km'
                }),
                status_code=400
            )
            
        if distance > RangeLimits.MAX_DISTANCE:
            return func.HttpResponse(
                json.dumps({
                    'error': f'Distance must be less than {RangeLimits.MAX_DISTANCE} km'
                }),
                status_code=400
            )
            
        if target_height is not None and target_height < 0:
            return func.HttpResponse(
                json.dumps({
                    'error': 'Target height must be at least 0 meters'
                }),
                status_code=400
            )
            
        if target_height is not None and target_height > RangeLimits.MAX_TARGET_HEIGHT:
            return func.HttpResponse(
                json.dumps({
                    'error': f'Target height must be less than {RangeLimits.MAX_TARGET_HEIGHT} meters'
                }),
                status_code=400
            )
            
        if refraction_factor <= 0:
            return func.HttpResponse(
                json.dumps({
                    'error': 'Refraction factor must be positive'
                }),
                status_code=400
            )

        calculator = CurvatureCalculator(
            observer_height=observer_height,
            distance=distance,
            refraction_factor=refraction_factor,
            is_metric=is_metric,
            target_height=target_height
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
