import math
from typing import Optional, Dict, Any

class CurvatureCalculator:
    def __init__(self, observer_height: float, distance: float, refraction_factor: float = 1.07, is_metric: bool = True, target_height: Optional[float] = None):
        self.observer_height = observer_height
        self.distance = distance
        self.refraction_factor = refraction_factor
        self.is_metric = is_metric
        self.target_height = target_height
        self.EARTH_RADIUS = 6371000.0  # meters

    def _convert_to_metric(self) -> None:
        if not self.is_metric:
            # Convert feet to meters
            self.observer_height = self.observer_height * 0.3048
            if self.target_height is not None:
                self.target_height = self.target_height * 0.3048
            # Convert miles to kilometers
            self.distance = self.distance * 1.60934

    def _convert_to_imperial(self, value_meters: float) -> float:
        return value_meters * 3.28084  # Convert meters to feet

    def calculate_horizon_distance(self) -> float:
        effective_radius = self.EARTH_RADIUS * self.refraction_factor
        horizon_distance = math.sqrt(2 * self.observer_height * effective_radius)
        return horizon_distance

    def calculate_hidden_height(self, total_distance: float, distance_to_horizon: float) -> float:
        effective_radius = self.EARTH_RADIUS * self.refraction_factor
        box_angle = total_distance / effective_radius
        oc = effective_radius + self.observer_height
        hidden_height = oc * (1 - math.cos(box_angle))
        return hidden_height

    def calculate_dip_angle(self) -> float:
        # Calculate geometric dip angle
        dip = math.acos(self.EARTH_RADIUS / (self.EARTH_RADIUS + self.observer_height)) * (180/math.pi)
        return dip

    def calculate(self) -> Dict[str, Any]:
        # Store original values before conversion
        original_distance = self.distance
        
        # Convert to metric for calculations
        self._convert_to_metric()
        
        # Convert distance to meters for calculations
        distance_meters = self.distance * 1000
        
        # Calculate distance to horizon
        horizon_distance = self.calculate_horizon_distance()
        horizon_distance_km = horizon_distance / 1000
        
        # Calculate hidden height
        hidden_height = self.calculate_hidden_height(distance_meters, horizon_distance)
        
        # Calculate geometric dip angle
        dip_angle = self.calculate_dip_angle()
        
        # Calculate target visibility if target height is provided
        result = {
            'hiddenHeight': hidden_height,
            'horizonDistance': round(horizon_distance_km if self.is_metric else horizon_distance_km * 0.621371, 4),
            'totalDistance': round(original_distance, 4),
            'dipAngle': dip_angle,
            'isMetric': self.is_metric
        }

        if self.target_height is not None:
            visible_height = max(0, self.target_height - hidden_height)
            perspective_scale = 1 - (distance_meters / (2 * self.EARTH_RADIUS))
            
            result.update({
                'visibleTargetHeight': visible_height,
                'apparentVisibleHeight': visible_height * perspective_scale,
                'perspectiveScaledHeight': self.target_height * perspective_scale,
                'targetVisible': visible_height > 0
            })

        return result
