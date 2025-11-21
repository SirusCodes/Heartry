import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';

class ShareImagesScreen extends StatelessWidget {
  const ShareImagesScreen({super.key, required this.images});

  final List<String> images;

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
                children: images
                    .map(
                      (path) => InkWell(
                        onTap: () {
                          SharePlus.instance.share(
                            ShareParams(
                              files: [XFile(path, mimeType: "image/png")],
                            ),
                          );
                        },
                        child: Card(child: Image.file(File(path))),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Platform.isIOS
          ? const OnlyBackButtonBottomAppBar()
          : null,
    );
  }
}
