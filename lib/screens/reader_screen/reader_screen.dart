import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import '../../database/config.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import '../../utils/share_helper.dart';
import '../../utils/poem_utils.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/share_option_list.dart';

import '../poems_screen/poems_screen.dart';
import '../writing_screen/writing_screen.dart';
import '../../widgets/constrained_width_container.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    this.model,
    this.poemId,
    this.isFromBin = false,
  });

  static const String routePath = '/reader/:id';
  static String route(int id, {bool bin = false}) =>
      '/reader/$id${bin ? "?bin=true" : ""}';

  final PoemModel? model;
  final int? poemId;
  final bool isFromBin;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  PoemModel? _poemModel;
  bool _isLoading = false;
  bool _error = false;
  QuillController? _quillController;

  final Database poemDB = locator<Database>();

  @override
  void initState() {
    super.initState();
    _poemModel = widget.model;

    if (_poemModel == null) {
      if (widget.poemId != null) {
        _isLoading = true;
        _loadPoemFromDb();
      } else {
        _error = true;
      }
    } else {
      _initializeQuill();
    }
  }

  void _initializeQuill() {
    final richText = _poemModel?.poemRich;
    final plainText = _poemModel?.poem ?? "";

    if (richText != null && richText.isNotEmpty) {
      try {
        _quillController = QuillController(
          document: Document.fromDelta(richText),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
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
          readOnly: true,
        );
      } catch (e) {
        // Not a JSON delta, treat as plain text
        _quillController = QuillController(
          document: Document()..insert(0, plainText),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      }
    } else {
      _quillController = QuillController(
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    }
  }

  Future<void> _loadPoemFromDb() async {
    final poem = await poemDB.getPoemById(widget.poemId!);
    if (!mounted) return;

    if (poem == null) {
      setState(() {
        _isLoading = false;
        _error = true;
      });
      return;
    }

    setState(() {
      _poemModel = poem;
      _isLoading = false;
      _initializeQuill();
    });
  }

  @override
  void dispose() {
    _quillController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (_error) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                "Poem not found",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(PoemScreen.routePath),
                icon: const Icon(Icons.home_rounded),
                label: const Text("Go back to home"),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading || _poemModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final model = _poemModel!;

    return Scaffold(
      body: ConstrainedWidthContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            CScreenTitle(title: model.title == "" ? "No title" : model.title),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: _quillController != null
                  ? QuillEditor.basic(
                      controller: _quillController!,
                      config: const QuillEditorConfig(
                        showCursor: false,
                        enableInteractiveSelection: true,
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ConstrainedWidthContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  isIOS
                      ? Icons.arrow_back_ios_rounded
                      : Icons.arrow_back_rounded,
                ),
                onPressed: () => context.pop(),
              ),
              if (widget.isFromBin) ...[
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    final result = await locator<Database>().hardDeletePoems([
                      model,
                    ]);

                    final String msg = result == 0
                        ? "Couldn't delete"
                        : "Deleted";

                    if (context.mounted) {
                      context.pop();
                    }
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        duration: Duration(seconds: result == 0 ? 5 : 2),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    final result = await locator<Database>().restorePoems([
                      model,
                    ]);

                    final String msg = result == 0
                        ? "Couldn't restore"
                        : "Restored";

                    if (context.mounted) {
                      context.pop();
                    }
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        duration: Duration(seconds: result == 0 ? 5 : 2),
                      ),
                    );
                  },
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.pushReplacement(
                      WritingScreen.route(model.id),
                      extra: model,
                    );
                  },
                ),
                IconButton(
                  onPressed: () => _showShareBottomSheet(context, model),
                  icon: const Icon(Icons.share),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showShareBottomSheet(BuildContext context, PoemModel model) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final poet = ref
              .watch(configProvider)
              .whenOrNull(data: (data) => data.name);

          return ShareOptionList(
            onShareAsImage: () => ShareHelper.shareAsImage(
              context,
              title: model.title,
              poem: model.poemRich,
              poet: poet ?? "Unknown",
            ),
            onShareAsText: () => ShareHelper.shareAsText(
              title: model.title,
              poem: model.poemRich.toMarkdown(),
              poet: poet ?? "Unknown",
            ),
          );
        },
      ),
    );
  }
}
