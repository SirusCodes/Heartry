import 'dart:async';

import 'package:flutter/cupertino.dart';
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

    _poemModel = widget.model ??
        PoemModel(
          id: null,
          lastEdit: null,
          title: null,
          poem: null,
        );

    _titleTextController = TextEditingController(text: _poemModel?.title);
    undoRedo.textEditingController =
        TextEditingController(text: _poemModel?.poem);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      undoRedo.registerChange(undoRedo.textEditingController.text);
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    titleNode.dispose();
    poemNode.dispose();
    searchOnStoppedTyping?.cancel();
    undoRedo.clearAllStack();

    _titleTextController.dispose();
    undoRedo.textEditingController.dispose();

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
      body: WillPopScope(
        onWillPop: () {
          if (_isEmpty && widget.model != null) poemDB.deletePoem(widget.model);

          return Future.value(true);
        },
        child: SafeArea(
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
                      style: const TextStyle(fontSize: 24),
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: undoRedo.textEditingController,
                      scrollPadding: const EdgeInsets.only(bottom: 100),
                      focusNode: poemNode,
                      maxLines: null,
                      minLines: 25,
                      decoration: const InputDecoration(
                        hintText: "Start writing your heart out....",
                        border: InputBorder.none,
                      ),
                      onChanged: _onChangeHandler,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: kBottomNavigationBarHeight)
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: WritingBottomAppBar(
                  title: _titleTextController.text,
                  poem: undoRedo.textEditingController.text,
                  showSharePanel: () {
                    if (undoRedo.textEditingController.text.isNotEmpty)
                      return true;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Please write something!"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(8.0),
                      ),
                    );

                    return false;
                  },
                  onShareAsText: () {
                    _handleDBChanges();
                  },
                  onShareAsImage: () {
                    _handleDBChanges();
                  },
                ),
              )
            ],
          ),
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

  bool get _hasChanged {
    return _poemModel.title != _titleTextController.text ||
        _poemModel.poem != undoRedo.textEditingController.text;
  }

  bool get _isNotEmpty =>
      (_titleTextController.text).isNotEmpty ||
      (undoRedo.textEditingController.text).isNotEmpty;

  bool get _isEmpty => !_isNotEmpty;

  void _handleDBChanges() {
    if (_hasChanged && _isNotEmpty) {
      if (_poemModel.id == null)
        _save();
      else
        _update();
    }
  }

  Future<void> _save() async {
    _poemModel = PoemModel(
      id: null,
      lastEdit: DateTime.now(),
      title: _titleTextController.text.trim(),
      poem: undoRedo.textEditingController.text.trim(),
    );
    final id = await poemDB.insertPoem(_poemModel);
    _poemModel = _poemModel.copyWith(id: id);
  }

  void _update() {
    _poemModel = _poemModel.copyWith(
      lastEdit: DateTime.now(),
      title: _titleTextController.text.trim(),
      poem: undoRedo.textEditingController.text.trim(),
    );
    poemDB.updatePoem(_poemModel);
  }
}
