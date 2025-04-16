import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/config.dart';
import '../../database/database.dart';
import '../../utils/share_helper.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/share_option_list.dart';
import '../writing_screen/writing_screen.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.model});

  final PoemModel model;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      body: ListView(
        children: [
          CScreenTitle(title: model.title == "" ? "No title" : model.title),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              model.poem,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (isIOS)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute(
                  builder: (_) => WritingScreen(
                    model: model,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _showShareBottomSheet(context),
              icon: const Icon(Icons.share),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showShareBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final poet = ref //
              .watch(configProvider)
              .whenOrNull(data: (data) => data.name);

          return ShareOptionList(
            onShareAsImage: () => ShareHelper.shareAsImage(
              context,
              title: model.title,
              poem: model.poem,
              poet: poet ?? "Unknown",
            ),
            onShareAsText: () => ShareHelper.shareAsText(
              title: model.title,
              poem: model.poem,
              poet: poet ?? "Unknown",
            ),
          );
        },
      ),
    );
  }
}
