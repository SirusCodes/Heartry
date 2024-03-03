import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/config.dart';
import '../../../database/database.dart';
import '../../../init_get_it.dart';
import '../../../providers/list_grid_provider.dart';
import '../../../utils/share_helper.dart';
import '../../../widgets/share_option_list.dart';
import '../../reader_screen/reader_screen.dart';
import '../../writing_screen/writing_screen.dart';

class PoemCard extends StatefulWidget {
  const PoemCard({Key? key, required this.model}) : super(key: key);

  final PoemModel model;

  @override
  State<PoemCard> createState() => _PoemCardState();
}

class _PoemCardState extends State<PoemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconList = [
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: () => _shareClicked(),
      ),
      IconButton(
        icon: const Icon(Icons.remove_red_eye_rounded),
        onPressed: () => _navigateToReaderScreen(),
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _showWarning(),
      ),
      IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => _controller.reverse(),
      ),
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(2, 1, .0003)
            ..rotateY(math.pi * _controller.value),
          child: _controller.value < .5
              ? OutlinedButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WritingScreen(model: widget.model),
                      ),
                    );
                  },
                  onLongPress: () {
                    _controller.forward();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (widget.model.title.isNotEmpty)
                        Text(
                          widget.model.title,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 5),
                      if (widget.model.poem.isNotEmpty)
                        Text(
                          widget.model.poem,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 10,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                )
              : Transform(
                  alignment: FractionalOffset.center,
                  transform: Matrix4.identity()
                    ..setEntry(2, 1, .0003)
                    ..rotateY(math.pi),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Theme.of(context).primaryColor,
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.white),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final listGrid = ref.watch(listGridProvider);
                          return listGrid
                              ? GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: iconList,
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: iconList,
                                );
                        },
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _shareClicked() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final poet = ref //
              .watch(configProvider)
              .whenOrNull(data: (data) => data.name);

          return ShareOptionList(
            onShareAsImage: () => ShareHelper.shareAsImage(
              context,
              title: widget.model.title,
              poem: widget.model.poem,
              poet: poet ?? "Unknown",
            ),
            onShareAsText: () => ShareHelper.shareAsText(
              title: widget.model.title,
              poem: widget.model.poem,
              poet: poet ?? "Unknown",
            ),
          );
        },
      ),
    );
  }

  void _navigateToReaderScreen() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          model: widget.model,
        ),
      ),
    );
  }

  void _showWarning() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Do you really want to delete it?"),
        content: const Text("There would be no other way to get back you art."
            " Are you really sure?"),
        actions: [
          TextButton(
            onPressed: () => _delete(),
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await locator<Database>().deletePoem(widget.model);

    final String msg = result == 0 ? "Failed to delete" : "Deleted";

    navigator.pop();

    scaffoldMessenger.showSnackBar(SnackBar(content: Text(msg)));
  }
}
