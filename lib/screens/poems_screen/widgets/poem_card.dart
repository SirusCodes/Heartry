import 'package:flutter/material.dart';

class PoemCard extends StatelessWidget {
  const PoemCard({
    Key key,
    @required this.title,
    @required this.poem,
  }) : super(key: key);

  final String title, poem;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.start,
            style: Theme.of(context).accentTextTheme.headline5,
          ),
          Text(
            poem,
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
