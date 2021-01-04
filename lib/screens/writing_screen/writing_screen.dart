import 'dart:async';

import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../init_get_it.dart';
import '../../utils/undo_redo.dart';
import 'widgets/writing_bottom_app_bar.dart';

class WritingScreen extends StatefulWidget {
  const WritingScreen({Key key, this.model}) : super(key: key);

  final PoemModel model;

  @override
  _WritingScreenState createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen>
    with WidgetsBindingObserver {
  FocusNode titleNode, poemNode;

  final undoRedo = locator<UndoRedo>();
  final poemDB = locator<Database>();

  PoemModel _poemModel;

  Timer searchOnStoppedTyping;

  TextEditingController _titleTextController;

  @override
  void initState() {
    super.initState();
    titleNode = FocusNode();
    poemNode = FocusNode();

    _poemModel = widget.model;

    _titleTextController = TextEditingController(text: _poemModel?.title);
    undoRedo.textEditingController =
        TextEditingController(text: _poemModel?.poem);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    titleNode.dispose();
    poemNode.dispose();
    searchOnStoppedTyping?.cancel();
    undoRedo.clearAllStack();

    _handleDBChanges();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _handleDBChanges();
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
                    controller: _titleTextController,
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

  void _handleDBChanges() {
    if (_poemModel.title != _titleTextController.text ||
        _poemModel.poem != undoRedo.textEditingController.text) {
      if (_poemModel == null) {
        _save();
        print("save");
      } else {
        _update();
        print("update");
      }
    }
  }

  void _save() {
    _poemModel = PoemModel(
      id: null,
      lastEdit: DateTime.now(),
      title: _titleTextController.text,
      poem: undoRedo.textEditingController.text,
    );
    poemDB.insertPoem(_poemModel);
  }

  void _update() {
    _poemModel = _poemModel.copyWith(
      lastEdit: DateTime.now(),
      title: _titleTextController.text,
      poem: undoRedo.textEditingController.text,
    );
    poemDB.updatePoem(_poemModel);
  }
}
