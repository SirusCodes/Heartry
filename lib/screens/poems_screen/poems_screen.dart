import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../writing_screen/writing_screen.dart';
import 'widgets/c_app_bar.dart';
import 'widgets/c_body.dart';
import 'widgets/poem_bottom_app_bar.dart';

class PoemScreen extends StatelessWidget {
  const PoemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const SliverToBoxAdapter(
              child: CAppBar(),
            ),
          ],
          body: const CBody(),
        ),
      ),
      floatingActionButton: OpenContainer(
        closedColor:
            Theme.of(context).floatingActionButtonTheme.backgroundColor!,
        openBuilder: (_, __) => const WritingScreen(),
        closedShape: const CircleBorder(),
        closedBuilder: (_, __) => AbsorbPointer(
          child: FloatingActionButton(
            elevation: 10,
            onPressed: () {},
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const PoemBottomAppBar(),
    );
  }
}
