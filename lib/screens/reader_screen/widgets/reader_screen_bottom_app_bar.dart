import 'dart:io';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:heartry/utils/share_helper.dart';

import '../../../database/database.dart';
import '../../../widgets/share_option_list.dart';
import '../../writing_screen/writing_screen.dart';

class ReaderScreenBottomAppBar extends StatefulWidget {
  const ReaderScreenBottomAppBar({
    Key? key,
    required this.model,
  }) : super(key: key);

  final PoemModel model;

  @override
  _ReaderScreenBottomAppBarState createState() =>
      _ReaderScreenBottomAppBarState();
}

class _ReaderScreenBottomAppBarState extends State<ReaderScreenBottomAppBar>
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (Platform.isIOS)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.pushReplacement<void, void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WritingScreen(
                      model: widget.model,
                    ),
                  ),
                ),
              ),
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
          ),
          SizeTransition(
            sizeFactor: _iconController,
            child: ShareOptionList(
              onShareAsImage: () => ShareHelper.shareAsImage(
                context,
                title: widget.model.title,
                poem: widget.model.poem,
              ),
              onShareAsText: () => ShareHelper.shareAsText(
                title: widget.model.title,
                poem: widget.model.poem,
              ),
            ),
          )
        ],
      ),
    );
  }
}
