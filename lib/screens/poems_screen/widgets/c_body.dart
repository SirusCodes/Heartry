import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../providers/list_grid_provider.dart';
import '../../../providers/stream_poem_provider.dart';
import 'poem_card.dart';

class CBody extends ConsumerWidget {
  const CBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final isGrid = watch(listGridProvider).state;
    final poems = watch(streamPoemProvider);
    return poems.when(
      data: (poems) {
        return isGrid
            ? MasonryGridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.all(10.0),
                mainAxisSpacing: 10,
                itemBuilder: (context, index) {
                  final poem = poems[index];
                  return PoemCard(
                    model: poem,
                    key: ValueKey("${poem.lastEdit}-${poem.id}"),
                  );
                },
                itemCount: poems.length,
              )
            : ListView.builder(
                itemCount: poems.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: PoemCard(model: poems[index]),
                ),
              );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, st) => Center(
        child: Text(e.toString() + st.toString()),
      ),
    );
  }
}
