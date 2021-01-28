import 'dart:io';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';

import '../../../database/database.dart';
import '../../image_screen/image_screen.dart';
import '../../writing_screen/writing_screen.dart';

class ReaderScreenBottomAppBar extends StatefulWidget {
  const ReaderScreenBottomAppBar({
    Key key,
    @required this.model,
  }) : super(key: key);

  final PoemModel model;

  @override
  _ReaderScreenBottomAppBarState createState() =>
      _ReaderScreenBottomAppBarState();
}

class _ReaderScreenBottomAppBarState extends State<ReaderScreenBottomAppBar>
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
                onPressed: () => Navigator.pushReplacement(
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
                startIcon: const Icon(Icons.share),
                endIcon: const Icon(Icons.close_rounded),
                onPressed: _changeIcon,
              ),
            ],
          ),
          SizeTransition(
            sizeFactor: _iconController,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text("Share as Text"),
                  trailing: const Icon(Icons.text_fields),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("Share as Image"),
                  trailing: const Icon(Icons.image),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageScreen(
                        title: widget.model.title,
                        poem: widget.model.poem.split("\n"),
                        poet: "Poet",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _changeIcon() {
    if (_iconController.isCompleted)
      _iconController.reverse();
    else
      _iconController.forward();
  }
}
