import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../../providers/list_grid_provider.dart';
import 'poem_card.dart';

class CBody extends ConsumerWidget {
  const CBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _isGrid = watch(listGridProvider).state;
    return _isGrid
        ? SliverPadding(
            padding: const EdgeInsets.all(10.0),
            sliver: SliverWaterfallFlow(
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return PoemCard(
                    title: "Title",
                    poem: "peom\n" * index,
                  );
                },
                childCount: 20,
              ),
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: PoemCard(
                    title: "Title",
                    poem: "peom\n" * index,
                  ),
                );
              },
              childCount: 20,
            ),
          );
  }
}
