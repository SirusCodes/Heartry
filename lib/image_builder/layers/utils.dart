part of '../core/image_layer.dart';

sealed class UtilsLayer extends ImageLayer {
  const UtilsLayer({super.key, required super.nextLayer});
}

class PaddingLayer extends UtilsLayer {
  const PaddingLayer({super.key, required this.padding, super.nextLayer});

  final EdgeInsets padding;

  factory PaddingLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
  ) {
    final h = (json['horizontal'] as num?)?.toDouble() ?? 40.0;
    final v = (json['vertical'] as num?)?.toDouble() ?? 50.0;
    return PaddingLayer(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
      nextLayer: nextLayer!,
    );
  }

  @override
  LayerType get type => LayerType.padding;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'horizontal': padding.left,
      'vertical': padding.top,
      'next': super.toJson(),
    };
  }

  @override
  EdgeInsets getPadding() {
    return padding + super.getPadding();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: nextLayer!.build(context));
  }
}

class PageCounterLayer extends UtilsLayer {
  const PageCounterLayer({
    super.key,
    super.nextLayer,
    required this.controller,
  });

  final ImageController controller;

  factory PageCounterLayer.fromJson(
    Map<String, dynamic> json,
    ImageLayer? nextLayer,
    ImageController controller,
  ) {
    return PageCounterLayer(controller: controller, nextLayer: nextLayer!);
  }

  @override
  LayerType get type => LayerType.pageCounter;

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.value, 'next': super.toJson()};
  }

  @override
  Widget build(BuildContext context) {
    final total = controller.poemSeparated.length;
    final currentPage = PageDetails.of(context).currentPage;

    return Stack(
      children: [
        if (total > 1)
          Positioned(
            top: 20,
            right: 20,
            child: Consumer(
              builder: (context, ref, child) {
                return Text(
                  "${currentPage + 1}/$total",
                  style: TextStyle(
                    fontSize: 17,
                    color: controller.textStyle.color,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: .5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        nextLayer!.build(context),
      ],
    );
  }
}
