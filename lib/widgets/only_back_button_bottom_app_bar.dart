import 'package:flutter/material.dart';

class OnlyBackButtonBottomAppBar extends StatelessWidget {
  const OnlyBackButtonBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: AutomaticNotchedShape(
        const RoundedRectangleBorder(),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
