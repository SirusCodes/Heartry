part of '../core/image_layer.dart';

sealed class FrameLayer extends ImageLayer {
  const FrameLayer({super.key, required super.nextLayer});
}

class FrostedGlassLayer extends FrameLayer {
  const FrostedGlassLayer({super.key, super.nextLayer});

  factory FrostedGlassLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
  ) {
    return FrostedGlassLayer(nextLayer: nextLayer!);
  }

  @override
  LayerType get type => LayerType.frostedGlass;

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.value, 'next': super.toJson()};
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment.topLeft,
              begin: Alignment.bottomRight,
              colors: <Color>[
                Colors.white.withValues(alpha: .2),
                Colors.white.withValues(alpha: .05),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: nextLayer!.build(context),
        ),
      ),
    );
  }
}
