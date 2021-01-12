import 'package:flutter/material.dart';

import '../../../database/database.dart';
import '../../../init_get_it.dart';
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
  AnimationController _sizeController;

  @override
  void initState() {
    _sizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    super.initState();
  }

  @override
  void dispose() {
    _sizeController?.dispose();
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
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              _sizeController.isCompleted
                  ? IconButton(
                      onPressed: _shareClicked,
                      icon: const Icon(Icons.close),
                    )
                  : PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        _popupMenuItem(
                            icon: const Icon(Icons.delete), title: "Delete"),
                        _popupMenuItem(
                            icon: const Icon(Icons.edit), title: "Edit"),
                        _popupMenuItem(
                            icon: const Icon(Icons.share), title: "Share"),
                      ],
                      onSelected: (String value) {
                        switch (value) {
                          case "Delete":
                            _showWarning(context);
                            break;
                          case "Edit":
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WritingScreen(model: widget.model),
                              ),
                            );
                            break;
                          case "Share":
                            _shareClicked();
                            break;
                        }
                      },
                    )
            ],
          ),
          SizeTransition(
            sizeFactor: _sizeController,
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

  Future<void> _shareClicked() async {
    if (_sizeController.isCompleted)
      await _sizeController.reverse();
    else
      await _sizeController.forward();

    setState(() {});
  }

  PopupMenuItem<String> _popupMenuItem({
    @required Icon icon,
    @required String title,
  }) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: <Widget>[
          icon,
          const SizedBox(width: 15),
          Text(title),
        ],
      ),
    );
  }

  void _showWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Do you really want to delete it?"),
        content: const Text("There would be no other way to get back you art."
            " Are you really sure?"),
        actions: [
          TextButton(
            onPressed: () => _delete(context),
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

  Future<void> _delete(BuildContext context) async {
    final result = await locator<Database>().deletePoem(widget.model);

    String msg;
    if (result == null) {
      msg = "Failed to delete";
    } else {
      msg = "Deleted";
      Navigator.pop(context);
      Navigator.pop(context);
    }

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
