import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../../providers/list_grid_provider.dart';
import '../../../providers/stream_poem_provider.dart';
import 'poem_card.dart';

class CBody extends ConsumerWidget {
  const CBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _isGrid = watch(listGridProvider).state;
    final _poems = watch(streamPoemProvider);
    return _poems.when(
      data: (poems) {
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
                      return PoemCard(model: poems[index]);
                    },
                    childCount: poems.length,
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
                      child: PoemCard(model: poems[index]),
                    );
                  },
                  childCount: poems.length,
                ),
              );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, st) => SliverToBoxAdapter(
        child: Center(
          child: Text(e.toString() + st.toString()),
        ),
      ),
    );
  }
}
