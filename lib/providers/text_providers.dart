import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final textSizeProvider = StateProvider<double>((ref) => 1);

final textColorProvider = StateProvider<Color>((ref) => Colors.white);
