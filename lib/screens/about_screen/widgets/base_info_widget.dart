import 'package:flutter/material.dart';

class BaseInfoWidget extends StatelessWidget {
  const BaseInfoWidget({
    Key key,
    @required this.children,
    @required this.title,
  }) : super(key: key);

  final List<Widget> children;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).accentColor),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15.0),
              child: Text(
                title,
                style: Theme.of(context).accentTextTheme.bodyText1,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 10),
            ...children
          ],
        ),
      ),
    );
  }
}
