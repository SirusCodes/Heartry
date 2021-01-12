import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../widgets/c_screen_title.dart';
import 'widgets/reader_screen_bottom_app_bar.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({Key key, this.model}) : super(key: key);

  final PoemModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          CScreenTitle(title: model.title == "" ? "No title" : model.title),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              model.poem,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ReaderScreenBottomAppBar(model: model),
    );
  }
}
