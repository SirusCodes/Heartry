import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartry/utils/undo_redo.dart';

import '../../init_get_it.dart';
import 'widgets/writing_bottom_app_bar.dart';

class WritingScreen extends StatefulWidget {
  const WritingScreen({Key key}) : super(key: key);

  @override
  _WritingScreenState createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  FocusNode titleNode, poemNode;

  final undoRedo = locator<UndoRedo>();

  Timer searchOnStoppedTyping;

  void _onChangeHandler(String value) {
    const duration = Duration(milliseconds: 800);

    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping.cancel();
    }
    searchOnStoppedTyping = Timer(
      duration,
      () => undoRedo.registerChange(value),
    );
  }

  @override
  void initState() {
    super.initState();
    titleNode = FocusNode();
    poemNode = FocusNode();

    undoRedo.textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    titleNode.dispose();
    poemNode.dispose();
    searchOnStoppedTyping?.cancel();
    undoRedo.clearAllStack();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.all(15.0),
                children: <Widget>[
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    focusNode: titleNode,
                    decoration: InputDecoration(
                      hintText: "Title",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      titleNode.unfocus();
                      FocusScope.of(context).requestFocus(poemNode);
                    },
                    style: Theme.of(context).accentTextTheme.headline5,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: undoRedo.textEditingController,
                    scrollPadding: const EdgeInsets.only(bottom: 100),
                    focusNode: poemNode,
                    maxLines: null,
                    minLines: 25,
                    onChanged: _onChangeHandler,
                    decoration: const InputDecoration(
                      hintText: "Start writing your heart....",
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).accentTextTheme.headline6,
                  ),
                  const SizedBox(height: kBottomNavigationBarHeight)
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: const WritingBottomAppBar(),
            )
          ],
        ),
      ),
    );
  }
}
