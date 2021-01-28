import 'dart:io';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/undo_redo.dart';
import '../../../widgets/share_option_list.dart';

typedef BoolCallBack = bool Function();

class WritingBottomAppBar extends StatefulWidget {
  const WritingBottomAppBar({
    Key key,
    @required this.onShareAsImage,
    @required this.onShareAsText,
    @required this.showSharePanel,
    @required this.title,
    @required this.poem,
  }) : super(key: key);

  final VoidCallback onShareAsImage, onShareAsText;
  final BoolCallBack showSharePanel;
  final String title, poem;

  @override
  _WritingBottomAppBarState createState() => _WritingBottomAppBarState();
}

class _WritingBottomAppBarState extends State<WritingBottomAppBar>
    with SingleTickerProviderStateMixin {
  AnimationController _iconController;

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
    _iconController?.dispose();
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
                    startIcon: const Icon(Icons.share),
                    endIcon: const Icon(Icons.close_rounded),
                    onPressed: _changeIcon,
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
              title: widget.title,
              poem: widget.poem,
            ),
          )
        ],
      ),
    );
  }

  void _changeIcon() {
    if (!widget.showSharePanel()) return;
    if (_iconController.isCompleted)
      _iconController.reverse();
    else
      _iconController.forward();
  }
}
