import 'package:flutter/material.dart';

class CalculationSettings extends StatelessWidget {
  final bool isMetric;
  final bool useApiCalculations;
  final bool isCalculating;
  final ValueChanged<bool> onMetricChanged;
  final ValueChanged<bool> onCalculationModeChanged;

  const CalculationSettings({
    super.key,
    required this.isMetric,
    required this.useApiCalculations,
    required this.isCalculating,
    required this.onMetricChanged,
    required this.onCalculationModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        
        // Use column layout for narrow screens, row for wider screens
        Widget content = isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildControls(context),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildControls(context),
              );

        return Padding(
          padding: EdgeInsets.all(isNarrow ? 8.0 : 16.0),
          child: content,
        );
      },
    );
  }

  List<Widget> _buildControls(BuildContext context) {
    return [
      // Units toggle
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Units:', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Metric')),
              ButtonSegment(value: false, label: Text('Imperial')),
            ],
            selected: {isMetric},
            onSelectionChanged: (Set<bool> selected) => onMetricChanged(selected.first),
          ),
        ],
      ),
      const SizedBox(height: 8, width: 16),  // Spacing that works for both layouts
      // Calculation mode toggle
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mode:', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Local')),
              ButtonSegment(value: true, label: Text('API')),
            ],
            selected: {useApiCalculations},
            onSelectionChanged: isCalculating 
                ? null  // Disable during calculation
                : (Set<bool> selected) => onCalculationModeChanged(selected.first),
          ),
        ],
      ),
    ];
  }
}
