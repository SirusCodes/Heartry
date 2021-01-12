import 'package:flutter/material.dart';

import '../../../database/database.dart';
import '../../reader_screen/reader_screen.dart';
import '../../writing_screen/writing_screen.dart';

class PoemCard extends StatelessWidget {
  const PoemCard({Key key, @required this.model}) : super(key: key);

  final PoemModel model;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WritingScreen(model: model),
        ),
      ),
      onLongPress: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderScreen(
            model: model,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (model.title.isNotEmpty)
            Text(
              model.title,
              textAlign: TextAlign.start,
              style: Theme.of(context).accentTextTheme.headline5,
            ),
          if (model.poem.isNotEmpty)
            Text(
              model.poem,
              overflow: TextOverflow.ellipsis,
              maxLines: 10,
              textAlign: TextAlign.start,
              style: Theme.of(context).accentTextTheme.subtitle1,
            )
        ],
      ),
    );
  }
}
