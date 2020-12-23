import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:heartry/providers/list_grid_provider.dart';

import '../../widgets/c_bottom_app_bar.dart';
import 'widgets/c_app_bar.dart';
import 'widgets/poem_card.dart';

class PoemScreen extends StatelessWidget {
  const PoemScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer(
          builder: (context, watch, child) {
            final _isList = watch(listGridProvider).state;
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: CAppBar(),
                ),
                _isList
                    ? SliverToBoxAdapter(
                        child: StaggeredGridView.countBuilder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(10),
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          staggeredTileBuilder: (index) =>
                              const StaggeredTile.fit(1),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return const PoemCard();
                          },
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: PoemCard(),
                            );
                          },
                          childCount: 10,
                        ),
                      ),
              ],
            );
          },
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
