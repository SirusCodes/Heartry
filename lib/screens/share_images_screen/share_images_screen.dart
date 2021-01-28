import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';

class ShareImagesScreen extends StatelessWidget {
  const ShareImagesScreen({
    Key key,
    @required this.imagePaths,
  }) : super(key: key);

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: CScreenTitle(title: "Share Images"),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                childAspectRatio: 9 / 16,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: imagePaths
                    .map(
                      (path) => InkWell(
                        onTap: () {
                          Share.shareFiles([path], mimeTypes: ["image/png"]);
                        },
                        child: Image.file(File(path)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          Platform.isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }
}
