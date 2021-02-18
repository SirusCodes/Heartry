import 'package:flutter/material.dart';

import '../../settings_screen/settings_screen.dart';

class PoemBottomAppBar extends StatefulWidget {
  const PoemBottomAppBar({Key key}) : super(key: key);

  @override
  _PoemBottomAppBarState createState() => _PoemBottomAppBarState();
}

class _PoemBottomAppBarState extends State<PoemBottomAppBar>
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
      notchMargin: 6,
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
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
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
