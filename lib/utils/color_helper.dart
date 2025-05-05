import 'dart:math' as math;
import 'package:flutter/material.dart';

// FROM https://github.com/mchome/flutter_colorpicker/blob/9b4942b6e6fa79fb78661f95531106afd1ed5d9f/lib/src/utils.dart#L15
bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
  int v = math
      .sqrt(math.pow(backgroundColor.r, 2) * 0.299 +
          math.pow(backgroundColor.g, 2) * 0.587 +
          math.pow(backgroundColor.b, 2) * 0.114)
      .round();
  return v < 130 + bias ? true : false;
}
