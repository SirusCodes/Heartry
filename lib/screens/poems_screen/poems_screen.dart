import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../widgets/c_bottom_app_bar.dart';
import 'widgets/c_app_bar.dart';
import 'widgets/poem_card.dart';

class PoemScreen extends StatelessWidget {
  const PoemScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: CAppBar(),
            ),
            SliverToBoxAdapter(
              child: StaggeredGridView.countBuilder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const PoemCard();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const CBottomAppBar(),
    );
  }
}
