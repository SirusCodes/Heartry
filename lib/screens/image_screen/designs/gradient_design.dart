import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/screens/image_screen/core/customizations/text_color.dart';
import 'package:heartry/screens/image_screen/core/customizations/text_size.dart';

import '../../../providers/color_gradient_provider.dart';
import '../core/base_image_design.dart';
import '../core/customizations/gradient_background_color.dart';
import '../widgets/poem_image_text.dart';

class GradientDesign extends BaseImageDesign {
  GradientDesign({
    required super.title,
    required super.poem,
    required super.poet,
  });

  @override
  EdgeInsetsGeometry getContentMargin() {
    return const EdgeInsets.symmetric(
      horizontal: 50,
      vertical: 40,
    );
  }

  @override
  (double x, double y) extraSpacing() => (0, 10);

  @override
  Widget buildBackground(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Consumer(
      builder: (context, ref, child) {
        final gradientList = ref.watch(colorGradientListProvider(primaryColor));
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientList,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildContent(BuildContext context, List<String> pageContent) {
    return Padding(
      padding: getContentMargin(),
      child: PoemImageText(
        poem: pageContent,
        title: title,
        poet: poet,
      ),
    );
  }

  @override
  List<Widget> getCustomizationOptions(BuildContext context) {
    return [TextSize(), TextColor(), GradientBackgroundColor()];
  }
}
