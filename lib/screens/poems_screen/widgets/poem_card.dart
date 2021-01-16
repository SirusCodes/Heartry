import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../database/database.dart';
import '../../../init_get_it.dart';
import '../../reader_screen/reader_screen.dart';
import '../../writing_screen/writing_screen.dart';

class PoemCard extends StatefulWidget {
  const PoemCard({Key key, @required this.model}) : super(key: key);

  final PoemModel model;

  @override
  _PoemCardState createState() => _PoemCardState();
}

class _PoemCardState extends State<PoemCard>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(2, 1, .0003)
          ..rotateY(2 * math.pi * _controller.value),
        child: _controller.value < .5
            ? OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                onPressed: () {
                  _navigateToWritingScreen();
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
                        style: Theme.of(context).accentTextTheme.headline5,
                      ),
                    if (widget.model.poem.isNotEmpty)
                      Text(
                        widget.model.poem,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 10,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).accentTextTheme.subtitle1,
                      )
                  ],
                ),
              )
            : Card(
                color: Theme.of(context).primaryColor,
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _navigateToWritingScreen();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_rounded),
                        onPressed: () {
                          _navigateToReaderScreen();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showWarning();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.reverse();
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _navigateToWritingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WritingScreen(model: widget.model),
      ),
    );
  }

  void _navigateToReaderScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          model: widget.model,
        ),
      ),
    );
  }

  void _showWarning() {
    showDialog(
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
    final result = await locator<Database>().deletePoem(widget.model);

    final String msg = result == null ? "Failed to delete" : "Deleted";

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8.0),
      ),
    );
  }
}
