import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/writing_bottom_app_bar.dart';

class WritingScreen extends StatefulWidget {
  const WritingScreen({Key key}) : super(key: key);

  @override
  _WritingScreenState createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  FocusNode titleNode, poemNode;

  @override
  void initState() {
    super.initState();
    titleNode = FocusNode();
    poemNode = FocusNode();
  }

  @override
  void dispose() {
    titleNode.dispose();
    poemNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: <Widget>[
            TextFormField(
              textInputAction: TextInputAction.next,
              focusNode: titleNode,
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
              style: Theme.of(context).accentTextTheme.headline5,
            ),
            TextFormField(
              focusNode: poemNode,
              maxLines: null,
              minLines: 25,
              initialValue: "poem\n",
              decoration: const InputDecoration(
                hintText: "Start writing your heart....",
                border: InputBorder.none,
              ),
              style: Theme.of(context).accentTextTheme.headline6,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const WritingBottomAppBar(),
    );
  }
}
