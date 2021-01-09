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
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      openBuilder: (_, __) => WritingScreen(model: model),
      closedBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.deepPurple.shade100,
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
      ),
    );
  }
}
