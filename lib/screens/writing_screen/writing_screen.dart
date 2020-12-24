import 'package:flutter/material.dart';
import 'package:heartry/widgets/c_bottom_app_bar.dart';

class WritingScreen extends StatefulWidget {
  const WritingScreen({Key key}) : super(key: key);

  @override
  _WritingScreenState createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Title",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  style: Theme.of(context).accentTextTheme.headline5,
                ),
                TextFormField(
                  maxLines: null,
                  initialValue: "poem\n" * 100,
                  decoration: const InputDecoration(
                    hintText: "Start writing your heart....",
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).accentTextTheme.headline6,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CBottomAppBar(),
    );
  }
}
