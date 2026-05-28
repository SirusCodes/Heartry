import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../database/config.dart';
import '../../widgets/color_picker_dialog.dart';
import '../../widgets/gradient_palette_selector.dart';
import '../widgets/editing_option.dart';
import '../widgets/page_details.dart';
import '../widgets/poem_image_text.dart';
import '../widgets/slider_option.dart';
import 'font_family.dart';
import 'image_controller.dart';

part '../layers/background.dart';
part '../layers/overlay.dart';
part '../layers/frames.dart';
part '../layers/text.dart';
part '../layers/utils.dart';

sealed class ImageLayer extends StatelessWidget {
  const ImageLayer({super.key, required this.nextLayer});

  final ImageLayer? nextLayer;

  LayerType get type;

  T? findLayer<T extends ImageLayer>() {
    if (this is T) {
      return this as T;
    }

    return nextLayer?.findLayer<T>();
  }

  @mustCallSuper
  List<Widget> getEditingOptions(BuildContext context) {
    if (nextLayer == null) {
      return <Widget>[];
    }

    return nextLayer!.getEditingOptions(context);
  }

  @mustCallSuper
  EdgeInsets getPadding() {
    if (nextLayer == null) {
      return EdgeInsets.zero;
    }

    return nextLayer!.getPadding();
  }

  @mustCallSuper
  Map<String, dynamic>? toJson() {
    if (nextLayer == null) {
      return null;
    }

    return nextLayer?.toJson();
  }

  @mustCallSuper
  void dispose() {
    nextLayer?.dispose();
  }
}

enum LayerType {
  solidBackground('solid_background'),
  gradientBackground('gradient_background'),
  imageBackground('image_background'),
  blurOverlay('blur_overlay'),
  translucentOverlay('translucent_overlay'),
  bubbleOverlay('bubble_overlay'),
  frostedGlass('frosted_glass'),
  padding('padding'),
  pageCounter('page_counter'),
  text('text');

  final String value;
  const LayerType(this.value);

  static LayerType? fromValue(String value) {
    for (final type in LayerType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}
