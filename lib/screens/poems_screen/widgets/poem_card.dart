import 'package:flutter/material.dart';

class PoemCard extends StatelessWidget {
  const PoemCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            "Title",
            textAlign: TextAlign.start,
            style: Theme.of(context).accentTextTheme.headline5,
          ),
          Text(
            "Peom\nPoem \nPoem adindwnsafknnafnsNffabankjnjnskn nawfn nawnn awnfnskn\nwands\n bhwabjdbshbaf\n dbahbjBa\n bdhjbhjabhjbdjahb\nbehjsbhj",
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
