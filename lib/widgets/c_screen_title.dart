import 'package:flutter/material.dart';

class CScreenTitle extends StatelessWidget {
  const CScreenTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
          fontWeight: FontWeight.w600,
          fontFamily: "Caveat",
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
