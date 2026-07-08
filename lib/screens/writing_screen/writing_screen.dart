import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../database/config.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import '../../utils/share_helper.dart';
import '../../utils/poem_utils.dart';
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

  PoemModel? _poemModel;
  bool _isLoading = false;

  late TextEditingController _titleTextController;
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();
    titleNode = FocusNode();
    poemNode = FocusNode();

    _titleTextController = TextEditingController();

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
    final richText = _poemModel?.poemRich;
    final plainText = _poemModel?.poem ?? "";

    if (richText != null && richText.isNotEmpty) {
      try {
        _quillController = QuillController(
          document: Document.fromDelta(richText),
          selection: const TextSelection.collapsed(offset: 0),
        );
        return;
      } catch (_) {}
    }

    if (plainText.isNotEmpty) {
      try {
        final docJson = jsonDecode(plainText);
        _quillController = QuillController(
          document: Document.fromJson(docJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Not a JSON delta, treat as plain text
        _quillController = QuillController(
          document: Document()..insert(0, plainText),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _quillController = QuillController.basic();
    }
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
    _quillController.dispose();

    _titleTextController.dispose();

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
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _showSharePanel, icon: const Icon(Icons.share)),
        ],
      ),

      body: PopScope(
        onPopInvokedWithResult: (_, _) {
          if (_isEmpty && widget.model != null)
            poemDB.softDeletePoem(widget.model!);
        },
        child: SafeArea(
          child: ConstrainedWidthContainer(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
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
                      const SizedBox(height: 10),
                      Expanded(
                        child: QuillEditor.basic(
                          controller: _quillController,
                          focusNode: poemNode,
                          config: const QuillEditorConfig(
                            placeholder: "Start writing your heart out....",
                            scrollable: true,
                            autoFocus: false,
                            expands: true,
                          ),
                        ),
                      ),
                      QuillSimpleToolbar(
                        controller: _quillController,
                        config: const QuillSimpleToolbarConfig(
                          multiRowsDisplay: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showAlignmentButtons: false,
                          showInlineCode: false,
                          showSearchButton: false,
                          showSubscript: false,
                          showSuperscript: false,
                          showColorButton: false,
                          showBackgroundColorButton: false,
                          showLink: false,
                          showIndent: false,
                          showCodeBlock: false,
                          showListNumbers: false,
                          showListBullets: false,
                          showListCheck: false,
                          showQuote: false,
                        ),
                      ),
                    ],
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
        _poemModel?.poemRich != _quillController.document.toDelta();
  }

  bool get _isNotEmpty =>
      _titleTextController.text.isNotEmpty ||
      _quillController.document.toPlainText().trim().isNotEmpty;

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
    final plainText = _quillController.document.toPlainText();
    _poemModel = PoemModel(
      title: _titleTextController.text.trim(),
      poem: plainText.trim(),
      poemRich: _quillController.document.toDelta(),
    );
    final id = await poemDB.insertPoem(_poemModel!);
    _poemModel = _poemModel!.copyWith(id: Value(id));
  }

  void _update() {
    final plainText = _quillController.document.toPlainText();
    _poemModel = _poemModel!.copyWith(
      lastEdit: Value(DateTime.now()),
      title: _titleTextController.text.trim(),
      poem: plainText.trim(),
      poemRich: _quillController.document.toDelta(),
    );
    poemDB.updatePoem(_poemModel!);
  }

  Future<void> _showSharePanel() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return SafeArea(
              child: ShareOptionList(
                onShareAsText: () async {
                  final poet = await ref.read(
                    configProvider.selectAsync((model) => model.name),
                  );
                  ShareHelper.shareAsText(
                    title: _titleTextController.text,
                    poem: _quillController.document.toDelta().toMarkdown(),
                    poet: poet ?? "Anonymous",
                  );
                  _handleDBChanges();
                },
                onShareAsImage: () async {
                  final poet = await ref.read(
                    configProvider.selectAsync((model) => model.name),
                  );

                  if (!context.mounted) return;
                  ShareHelper.shareAsImage(
                    context,
                    title: _titleTextController.text,
                    poem: _quillController.document.toDelta(),
                    poet: poet ?? "Anonymous",
                  );
                  _handleDBChanges();
                },
              ),
            );
          },
        );
      },
    );
  }
}
