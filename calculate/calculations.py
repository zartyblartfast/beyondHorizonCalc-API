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
        """Calculate the distance to the horizon.
        
        Uses the Pythagorean theorem to calculate the distance to the horizon,
        accounting for the observer's height and the Earth's radius.
        
        Returns:
            Distance to the horizon in meters
        """
        effective_radius = self.EARTH_RADIUS * self.refraction_factor
        horizon_distance = math.sqrt(2 * self.observer_height * effective_radius)
        return horizon_distance

    def calculate_hidden_height(self, total_distance: float, distance_to_horizon: float) -> float:
        """Calculate the hidden height of an object due to Earth's curvature.
        
        Uses spherical geometry to calculate how much of an object would be hidden
        by the Earth's curvature at a given distance, accounting for atmospheric refraction.
        
        Args:
            total_distance: Total distance to the object in meters
            distance_to_horizon: Distance to the horizon in meters
            
        Returns:
            Hidden height in meters
        """
        effective_radius = self.EARTH_RADIUS * self.refraction_factor
        
        # Calculate BOX angle using spherical geometry
        circumference = 2 * math.pi * effective_radius
        l2 = total_distance - distance_to_horizon
        box_fraction = l2 / circumference
        box_angle = 2 * math.pi * box_fraction
        
        # Calculate hidden height using the secant method
        oc = effective_radius / math.cos(box_angle)
        hidden_height = oc - effective_radius
        return hidden_height

    def calculate_dip_angle(self) -> float:
        """Calculate the geometric dip angle.
        
        Uses the inverse cosine function to calculate the angle between the
        observer's line of sight and the horizon.
        
        Returns:
            Dip angle in degrees
        """
        # Calculate geometric dip angle
        dip = math.acos(self.EARTH_RADIUS / (self.EARTH_RADIUS + self.observer_height)) * (180/math.pi)
        return dip

    def calculate(self) -> Dict[str, Any]:
        """Calculate all curvature-related measurements.
        
        Performs calculations in metric units and converts results based on is_metric flag.
        All height values in the response are converted to kilometers for consistency
        with the Flutter app's expectations.
        
        Returns:
            Dictionary containing all calculated values including:
            - horizon_distance: Distance to the horizon in km/mi
            - hidden_height: Height hidden by Earth's curvature in km
            - visible_target_height: Visible portion of target in km (if target_height provided)
            - apparent_visible_height: Height accounting for viewing angle in km
            - perspective_scaled_height: Height accounting for perspective effect in km
        """
        # Store original values before conversion
        original_distance = self.distance
        
        # Convert to metric for calculations
        self._convert_to_metric()

        # Calculate horizon distance
        horizon_distance = self.calculate_horizon_distance()
        horizon_distance_km = horizon_distance / 1000

        # Calculate dip angle
        dip_angle = self.calculate_dip_angle()

        # Calculate hidden height
        hidden_height = self.calculate_hidden_height(self.distance * 1000, horizon_distance)
        distance_meters = self.distance * 1000

        # Calculate target visibility if target height is provided
        result = {
            'hidden_height': hidden_height / 1000,  # Convert to km
            'horizon_distance': round(horizon_distance_km if self.is_metric else horizon_distance_km * 0.621371, 4),
            'total_distance': round(original_distance, 4),
            'dip_angle': round(dip_angle, 2),  # Now dip_angle is calculated
            'is_metric': self.is_metric
        }

        if self.target_height is not None:
            visible_height = max(0, self.target_height - hidden_height)
            
            # Use the same perspective calculation as local calculator
            angle = distance_meters / (self.EARTH_RADIUS * self.refraction_factor)
            apparent_height = visible_height * math.cos(angle)
            
            # Calculate perspective scaled height using pinhole camera model
            # We use a 1km focal length to match the Flutter app's perspective scaling.
            # The pinhole model approximates how the human eye would perceive the
            # height at this distance, making distant objects appear smaller.
            FOCAL_LENGTH = 1000.0  # 1km focal length
            perspective_height = FOCAL_LENGTH * apparent_height / distance_meters
            perspective_height = max(0, perspective_height)
            
            result.update({
                'visible_target_height': visible_height / 1000,  # Convert to km
                'apparent_visible_height': apparent_height / 1000,  # Convert to km
                'perspective_scaled_height': perspective_height / 1000,  # Convert to km
                'target_visible': visible_height > 0
            })

        return result
