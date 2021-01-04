import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../database/database.dart';
import '../../writing_screen/writing_screen.dart';

class PoemCard extends StatelessWidget {
  const PoemCard({Key key, @required this.model}) : super(key: key);

  final PoemModel model;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      openBuilder: (_, __) => WritingScreen(model: model),
      closedBuilder: (_, __) => OutlinedButton(
        onPressed: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              model.title,
              textAlign: TextAlign.start,
              style: Theme.of(context).accentTextTheme.headline5,
            ),
            Text(
              model.poem,
              overflow: TextOverflow.ellipsis,
              maxLines: 10,
              textAlign: TextAlign.start,
              style: Theme.of(context).accentTextTheme.subtitle1,
            )
          ],
        ),
      ),
    );
  }
}
