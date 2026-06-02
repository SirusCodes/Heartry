import 'package:flutter/material.dart';

/// Reusable layout container that centers its child and constrains its maximum
/// width, with customizable padding. Prevents visual stretching on tablets,
/// foldables, and laptops.
class ConstrainedWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ConstrainedWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 800.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = child;
    if (padding != EdgeInsets.zero) {
      current = Padding(
        padding: padding,
        child: current,
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: current,
      ),
    );
  }
}
