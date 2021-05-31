import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final textSizeProvider = StateProvider<double>((ref) => 0.8);

final textColorProvider = StateProvider<Color>((ref) => Colors.white);
