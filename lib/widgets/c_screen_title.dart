import 'package:flutter/material.dart';

class CScreenTitle extends StatelessWidget {
  const CScreenTitle({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        title,
        style: Theme.of(context)
            .accentTextTheme
            .headline3
            .copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
