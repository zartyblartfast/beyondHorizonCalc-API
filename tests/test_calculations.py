import unittest
import math
import logging
from calculate.calculations import CurvatureCalculator
from calculate.constants import RangeLimits

# Set up logging
logging.basicConfig(
    filename='test_results.log',
    level=logging.INFO,
    format='%(message)s',
    filemode='a'
)

class TestCurvatureCalculator(unittest.TestCase):
    def setUp(self):
        # Add a separator between test runs
        logging.info('\n=== New Test Run ===\n')

    def test_horizon_distance_calculation(self):
        # Test with standard parameters (2m height, metric units)
        calculator = CurvatureCalculator(
            observer_height=2.0,  # meters
            distance=10.0,        # kilometers
            refraction_factor=1.07,
            is_metric=True
        )
        
        # Calculate expected horizon distance
        # Formula: sqrt(2 * h * R * k) where:
        # h = height in meters
        # R = Earth radius in meters
        # k = refraction factor
        expected_horizon_meters = math.sqrt(
            2 * 2.0 * calculator.EARTH_RADIUS * 1.07
        )
        
        # Get actual horizon distance
        actual_horizon_meters = calculator.calculate_horizon_distance()
        
        logging.info('\nHorizon Distance Test Results:')
        logging.info(f'Expected horizon distance: {expected_horizon_meters/1000:.3f} km')
        logging.info(f'Actual horizon distance:   {actual_horizon_meters/1000:.3f} km')
        
        # Assert they match within a small delta
        self.assertAlmostEqual(
            actual_horizon_meters,
            expected_horizon_meters,
            delta=0.001,
            msg="Horizon distance calculation does not match expected value"
        )

    def test_hidden_height_calculation(self):
        # Test with standard parameters
        calculator = CurvatureCalculator(
            observer_height=2.0,  # meters
            distance=10.0,        # kilometers
            refraction_factor=1.07,
            is_metric=True
        )
        
        # Calculate total distance and horizon distance
        total_distance = 10000  # 10km in meters
        horizon_distance = calculator.calculate_horizon_distance()
        
        # Get actual hidden height
        hidden_height = calculator.calculate_hidden_height(total_distance, horizon_distance)
        
        # Calculate expected hidden height
        # h = R(1 - cos(s/R)) where:
        # R = Earth radius * refraction factor
        # s = distance in meters
        effective_radius = calculator.EARTH_RADIUS * calculator.refraction_factor
        expected_height = effective_radius * (1 - math.cos(total_distance / effective_radius))
        
        logging.info('\nHidden Height Test Results:')
        logging.info(f'Total distance: {total_distance/1000:.3f} km')
        logging.info(f'Expected hidden height: {expected_height:.3f} m')
        logging.info(f'Actual hidden height:   {hidden_height:.3f} m')
        
        # Assert they match within a small delta
        self.assertAlmostEqual(
            hidden_height,
            expected_height,
            delta=0.001,
            msg="Hidden height calculation does not match expected value"
        )
        
        # Additional assertion: hidden height should be positive
        self.assertGreater(hidden_height, 0, "Hidden height should be positive")

    def test_dip_angle_calculation(self):
        # Test with standard parameters
        calculator = CurvatureCalculator(
            observer_height=2.0,  # meters
            distance=10.0,        # kilometers
            refraction_factor=1.07,
            is_metric=True
        )
        
        # Calculate actual dip angle
        actual_dip = calculator.calculate_dip_angle()
        
        # Calculate expected dip angle
        # Formula: arccos(R/(R + h)) where:
        # R = Earth radius
        # h = observer height in meters
        expected_dip = math.acos(
            calculator.EARTH_RADIUS / (calculator.EARTH_RADIUS + calculator.observer_height)
        ) * (180/math.pi)  # Convert to degrees
        
        logging.info('\nDip Angle Test Results:')
        logging.info(f'Observer height: {calculator.observer_height:.1f} m')
        logging.info(f'Expected dip angle: {expected_dip:.4f}°')
        logging.info(f'Actual dip angle:   {actual_dip:.4f}°')
        
        # Assert they match within a small delta
        self.assertAlmostEqual(
            actual_dip,
            expected_dip,
            delta=0.0001,
            msg="Dip angle calculation does not match expected value"
        )
        
        # Additional assertions
        self.assertGreater(actual_dip, 0, "Dip angle should be positive")
        self.assertLess(actual_dip, 90, "Dip angle should be less than 90 degrees")

    def test_complete_calculation_output(self):
        # Test with a target height to get all possible outputs
        calculator = CurvatureCalculator(
            observer_height=2.0,    # meters
            distance=10.0,          # kilometers
            target_height=100.0,    # meters
            refraction_factor=1.07,
            is_metric=True
        )
        
        # Get complete calculation results
        results = calculator.calculate()
        
        logging.info('\nComplete Calculation Results:')
        logging.info(f'Observer height: {calculator.observer_height:.1f} m')
        logging.info(f'Target height: {calculator.target_height:.1f} m')
        logging.info(f'Total distance: {results["totalDistance"]:.3f} km')
        logging.info(f'Horizon distance: {results["horizonDistance"]:.3f} km')
        logging.info(f'Hidden height: {results["hiddenHeight"]:.3f} m')
        logging.info(f'Dip angle: {results["dipAngle"]:.4f}°')
        logging.info(f'Visible target height: {results["visibleTargetHeight"]:.3f} m')
        logging.info(f'Apparent visible height: {results["apparentVisibleHeight"]:.3f} m')
        logging.info(f'Perspective scaled height: {results["perspectiveScaledHeight"]:.3f} m')
        logging.info(f'Target visible: {results["targetVisible"]}')
        
        # Assertions for all values
        self.assertGreater(results["hiddenHeight"], 0, "Hidden height should be positive")
        self.assertGreater(results["horizonDistance"], 0, "Horizon distance should be positive")
        self.assertEqual(results["totalDistance"], 10.0, "Total distance should match input")
        self.assertGreater(results["dipAngle"], 0, "Dip angle should be positive")
        self.assertTrue(results["isMetric"], "Should be in metric units")
        
        # Target-specific assertions
        self.assertGreater(results["visibleTargetHeight"], 0, "Target should be partially visible")
        self.assertLess(results["apparentVisibleHeight"], results["visibleTargetHeight"], 
                       "Apparent height should be less than actual visible height due to perspective")
        self.assertTrue(results["targetVisible"], "Target should be visible")

if __name__ == '__main__':
    unittest.main()
