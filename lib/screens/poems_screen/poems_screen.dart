import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/screens/writing_screen/writing_screen.dart';

import 'widgets/poem_bottom_app_bar.dart';
import 'widgets/c_app_bar.dart';
import 'widgets/c_body.dart';

class PoemScreen extends StatelessWidget {
  const PoemScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer(
          builder: (context, watch, child) {
            return const CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CAppBar(),
                ),
                CBody(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: OpenContainer(
        openBuilder: (_, __) => const WritingScreen(),
        closedShape: const CircleBorder(),
        closedColor: Theme.of(context).primaryColor,
        closedBuilder: (_, __) => const Padding(
          padding: EdgeInsets.all(14.0),
          child: IconTheme(
            data: IconThemeData(
              color: Colors.white,
            ),
            child: Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const PoemBottomAppBar(),
    );
  }
}
