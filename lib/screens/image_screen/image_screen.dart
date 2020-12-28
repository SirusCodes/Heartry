import 'package:flutter/material.dart';

import 'widgets/image_bottom_app_bar.dart';
import 'widgets/image_color_handler.dart';
import 'widgets/poem_image_widget.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Center(
          child: PoemImageWidget(),
        ),
      ),
      bottomNavigationBar: ImageBottomAppBar(
        onTextPressed: () {},
        onColorPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            builder: (context) {
              return const ImageColorHandler();
            },
          );
        },
        onDonePressed: () {},
      ),
    );
  }
}
