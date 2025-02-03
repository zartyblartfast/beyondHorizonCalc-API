import 'package:flutter/material.dart';

class ApiToggle extends StatelessWidget {
  final bool useApiCalculations;
  final ValueChanged<bool>? onChanged;

  const ApiToggle({
    super.key,
    required this.useApiCalculations,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Using ${useApiCalculations ? "API" : "local"} calculations',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Switch(
          value: useApiCalculations,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
