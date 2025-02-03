import 'package:flutter/material.dart';
import '../../services/models/calculation_result.dart';
import '../../services/models/calculation_error.dart';
import '../common/info_icon.dart';

class ResultsDisplay extends StatelessWidget {
  final CalculationResult? result;
  final bool isMetric;
  final double? targetHeight;

  const ResultsDisplay({
    super.key,
    required this.result,
    required this.isMetric,
    this.targetHeight,
  });

  String _formatDistance(double? value) {
    if (value == null) return 'N/A';
    final double displayValue = isMetric ? value : value * 0.621371; // km to mi
    return '${displayValue.toStringAsFixed(2)} ${isMetric ? 'km' : 'mi'}';
  }

  String _formatHeight(double? value) {
    if (value == null) return 'N/A';
    final double displayValue = isMetric ? value * 1000 : value * 3280.84; // km to m, or km to ft
    return '${displayValue.toStringAsFixed(1)} ${isMetric ? 'm' : 'ft'}';
  }

  String _getDiagramAsset() {
    if (result == null) return 'assets/svg/BTH_1.svg';
    
    // If target height is null or 0, show BTH_1
    if (targetHeight == null || targetHeight == 0) {
      return 'assets/svg/BTH_1.svg';
    }
    
    // Get h2 (XC) from the hiddenHeight
    final double? h2 = result!.hiddenHeight;
    if (h2 == null) return 'assets/svg/BTH_1.svg';
    
    // Compare target height with h2
    if (targetHeight! < h2) {
      return 'assets/svg/BTH_2.svg';
    } else if ((targetHeight! - h2).abs() < 0.000001) { // Use small epsilon for floating point comparison
      return 'assets/svg/BTH_3.svg';
    } else {
      return 'assets/svg/BTH_4.svg';
    }
  }

  Widget _buildResultRow(String label, String value, {String? infoKey}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 2.0 : 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SelectableText(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (infoKey != null) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        child: Center(
                          child: InfoIcon(
                            infoKey: infoKey,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SelectableText(
                  value,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        Widget content;
        if (result!.isError) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Calculation Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                result!.error!.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (result!.error!.details != null) ...[
                const SizedBox(height: 8),
                SelectableText(
                  'Technical Details:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SelectableText(
                  result!.error!.details!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
            ],
          );
        } else {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildResultRow(
                'Distance to Horizon (D1)',
                _formatDistance(result!.horizonDistance),
                infoKey: 'horizon_distance',
              ),
              _buildResultRow(
                'Horizon Dip Angle',
                '${result!.dipAngle?.toStringAsFixed(2) ?? 'N/A'}°',
                infoKey: 'dip_angle',
              ),
              _buildResultRow(
                'Hidden Height (h2, XC)',
                _formatHeight(result!.hiddenHeight),
                infoKey: 'hidden_height',
              ),
              if (targetHeight != null) ...[
                _buildResultRow(
                  'Visible Height (h3)',
                  _formatHeight(result!.visibleTargetHeight!),
                  infoKey: 'visible_height',
                ),
                _buildResultRow(
                  'Apparent Visible Height (CD)',
                  _formatHeight(result!.apparentVisibleHeight!),
                  infoKey: 'apparent_height',
                ),
                _buildResultRow(
                  'Perspective Scaled Apparent Visible Height',
                  _formatHeight(result!.perspectiveScaledHeight!),
                  infoKey: 'perspective_scaled_height',
                ),
              ],
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
          child: content,
        );
      },
    );
  }
}
