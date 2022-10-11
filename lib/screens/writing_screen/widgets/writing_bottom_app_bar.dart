import 'dart:io';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/undo_redo.dart';
import '../../../widgets/share_option_list.dart';

typedef BoolCallBack = bool Function();

class WritingBottomAppBar extends StatefulWidget {
  const WritingBottomAppBar({
    Key? key,
    required this.onShareAsImage,
    required this.onShareAsText,
    required this.showSharePanel,
  }) : super(key: key);

  final VoidCallback onShareAsImage, onShareAsText;
  final BoolCallBack showSharePanel;

  @override
  _WritingBottomAppBarState createState() => _WritingBottomAppBarState();
}

class _WritingBottomAppBarState extends State<WritingBottomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;

  @override
  void initState() {
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    super.initState();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer(
            builder: (context, watch, child) {
              final undoRedo = watch(undoRedoProvider);
              return Row(
                children: <Widget>[
                  if (Platform.isIOS)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  if (!Platform.isIOS) const SizedBox(width: 48),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.undo_rounded),
                    onPressed: undoRedo.canUndo ? undoRedo.undo : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo_rounded),
                    onPressed: undoRedo.canRedo ? undoRedo.redo : null,
                  ),
                  const Spacer(),
                  AnimatedIconButton(
                    size: 25,
                    animationController: _iconController,
                    icons: [
                      AnimatedIconItem(
                        icon: Icon(
                          Icons.share,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      AnimatedIconItem(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizeTransition(
            sizeFactor: _iconController,
            child: ShareOptionList(
              onShareAsImage: () => widget.onShareAsImage(),
              onShareAsText: () => widget.onShareAsText(),
            ),
          )
        ],
      ),
    );
  }
}
