import 'package:flutter/material.dart';

class CAppBar extends StatelessWidget {
  const CAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15.0,
        left: 15.0,
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Heartry",
            style: Theme.of(context)
                .accentTextTheme
                .headline3
                .copyWith(fontWeight: FontWeight.w500),
          ),
          const CircleAvatar()
        ],
      ),
    );
  }
}
