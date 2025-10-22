import 'package:flutter/material.dart';

class EditingOption extends StatelessWidget {
  const EditingOption({
    super.key,
    required this.option,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final String option, tooltip;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: onPressed,
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              icon,
              Text(
                option,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
