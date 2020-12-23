import 'package:flutter/material.dart';

class CBottomAppBar extends StatefulWidget {
  const CBottomAppBar({Key key}) : super(key: key);

  @override
  _CBottomAppBarState createState() => _CBottomAppBarState();
}

class _CBottomAppBarState extends State<CBottomAppBar>
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
      shape: const CircularNotchedRectangle(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: <Widget>[
              IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _iconController,
                ),
                onPressed: _changeIcon,
              )
            ],
          ),
          SizeTransition(
            sizeFactor: _iconController,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text("Settings"),
                  trailing: const Icon(Icons.settings),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("About"),
                  trailing: const Icon(Icons.person),
                  onTap: () {},
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
