import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';

import '../../database/config.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import '../../utils/share_helper.dart';
import '../../widgets/share_option_list.dart';
import '../../widgets/constrained_width_container.dart';

class WritingScreen extends StatefulWidget {
  const WritingScreen({super.key, this.model, this.poemId});

  static const String routePath = '/writing';
  static const String routePathWithId = '/writing/:id';
  static String route([int? id]) => id == null ? '/writing' : '/writing/$id';

  final PoemModel? model;
  final int? poemId;

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen>
    with WidgetsBindingObserver {
  late FocusNode titleNode, poemNode;

  final Database poemDB = locator<Database>();
  final UndoHistoryController _undoController = UndoHistoryController();

  PoemModel? _poemModel;
  bool _isLoading = false;

  late TextEditingController _titleTextController;
  late TextEditingController _poemTextController;

  @override
  void initState() {
    super.initState();
    titleNode = FocusNode();
    poemNode = FocusNode();

    _titleTextController = TextEditingController();
    _poemTextController = TextEditingController();

    _poemModel = widget.model;

    if (_poemModel == null && widget.poemId != null) {
      _isLoading = true;
      _loadPoemFromDb();
    } else {
      _initializeControllers();
    }

    WidgetsBinding.instance.addObserver(this);
  }

  void _initializeControllers() {
    _titleTextController.text = _poemModel?.title ?? "";
    _poemTextController.text = _poemModel?.poem ?? "";
  }

  Future<void> _loadPoemFromDb() async {
    final poem = await poemDB.getPoemById(widget.poemId!);
    if (!mounted) return;

    if (poem == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(WritingScreen.routePath);
        }
      });
      return;
    }

    setState(() {
      _poemModel = poem;
      _isLoading = false;
      _initializeControllers();
    });
  }

  @override
  void dispose() {
    titleNode.dispose();
    poemNode.dispose();
    _undoController.dispose();

    _titleTextController.dispose();
    _poemTextController.dispose();

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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: PopScope(
        onPopInvokedWithResult: (_, __) {
          if (_isEmpty && widget.model != null)
            poemDB.softDeletePoem(widget.model!);
        },
        child: SafeArea(
          child: ConstrainedWidthContainer(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      top: 15.0,
                      bottom: kBottomNavigationBarHeight + 20,
                    ),
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
                              color: Theme.of(context).colorScheme.secondary,
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
                        controller: _poemTextController,
                        undoController: _undoController,
                        scrollPadding: const EdgeInsets.only(bottom: 100),
                        focusNode: poemNode,
                        maxLines: null,
                        minLines: 25,
                        decoration: const InputDecoration(
                          hintText: "Start writing your heart out....",
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: kBottomNavigationBarHeight),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final poet = ref
                          .watch(configProvider)
                          .whenOrNull(data: (data) => data.name);
                      return _WritingBottomAppBar(
                        onShareAsText: () {
                          ShareHelper.shareAsText(
                            title: _titleTextController.text,
                            poem: _poemTextController.text,
                            poet: poet ?? "Anonymous",
                          );
                          _handleDBChanges();
                        },
                        onShareAsImage: () {
                          ShareHelper.shareAsImage(
                            context,
                            title: _titleTextController.text,
                            poem: _poemTextController.text,
                            poet: poet ?? "Anonymous",
                          );
                          _handleDBChanges();
                        },
                        undoController: _undoController,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasChanged {
    return _poemModel?.title != _titleTextController.text ||
        _poemModel?.poem != _poemTextController.text;
  }

  bool get _isNotEmpty =>
      (_titleTextController.text).isNotEmpty ||
      (_poemTextController.text).isNotEmpty;

  bool get _isEmpty => !_isNotEmpty;

  void _handleDBChanges() {
    if (_hasChanged && _isNotEmpty) {
      if (_poemModel == null)
        _save();
      else
        _update();
    }
  }

  Future<void> _save() async {
    _poemModel = PoemModel(
      title: _titleTextController.text.trim(),
      poem: _poemTextController.text.trim(),
    );
    final id = await poemDB.insertPoem(_poemModel!);
    _poemModel = _poemModel!.copyWith(id: Value(id));
  }

  void _update() {
    _poemModel = _poemModel!.copyWith(
      lastEdit: Value(DateTime.now()),
      title: _titleTextController.text.trim(),
      poem: _poemTextController.text.trim(),
    );
    poemDB.updatePoem(_poemModel!);
  }
}

class _WritingBottomAppBar extends StatelessWidget {
  const _WritingBottomAppBar({
    required this.onShareAsImage,
    required this.onShareAsText,
    required this.undoController,
  });

  final VoidCallback onShareAsImage, onShareAsText;
  final UndoHistoryController undoController;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return BottomAppBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<UndoHistoryValue>(
            valueListenable: undoController,
            builder: (context, undoState, child) {
              return Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      isIOS
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_back_rounded,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.undo_rounded),
                    onPressed: undoState.canUndo ? undoController.undo : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo_rounded),
                    onPressed: undoState.canRedo ? undoController.redo : null,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showSharePanel(context),
                    icon: const Icon(Icons.share),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showSharePanel(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return ShareOptionList(
          onShareAsImage: onShareAsImage,
          onShareAsText: onShareAsText,
        );
      },
    );
  }
}
