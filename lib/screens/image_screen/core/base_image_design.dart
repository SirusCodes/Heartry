import 'package:flutter/material.dart';

abstract class BaseImageDesign {
  const BaseImageDesign({
    required this.title,
    required this.poem,
    required this.poet,
  });

  final String? title, poet;
  final List<String> poem;

  Widget buildContent(BuildContext context, List<String> pageContent);

  Widget buildBackground(BuildContext context);

  EdgeInsetsGeometry getContentMargin();

  (double x, double y) extraSpacing();

  List<Widget> getCustomizationOptions(BuildContext context);
}
