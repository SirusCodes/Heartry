import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';

import '../../database/database.dart';
import '../../init_get_it.dart';
import '../../providers/list_grid_provider.dart';
import '../../providers/stream_poem_provider.dart';
import '../../widgets/constrained_width_container.dart';
import '../poems_screen/providers/multi_select_provider.dart';
import '../poems_screen/widgets/poem_card.dart';
import '../reader_screen/reader_screen.dart';

class BinScreen extends StatelessWidget {
  const BinScreen({super.key});

  static const String routePath = '/bin';

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        selectedPoemsProvider.overrideWith((_) => SelectedPoems()),
        multiSelectEnabledProvider.overrideWith(
          (ref) => ref.watch(selectedPoemsProvider).isNotEmpty,
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: ConstrainedWidthContainer(
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (_, __) => [
                const SliverToBoxAdapter(child: _CAppBar()),
              ],
              body: const _CBody(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CAppBar extends ConsumerWidget {
  const _CAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMultiOption = ref.watch(multiSelectEnabledProvider);

    return AnimatedCrossFade(
      firstChild: _DefaultAppBar(),
      secondChild: _Toolbar(),
      crossFadeState: showMultiOption
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 100),
    );
  }
}

class _DefaultAppBar extends ConsumerWidget {
  const _DefaultAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(listGridProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Bin",
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: "Caveat",
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              ref.read(listGridProvider.notifier).state = !ref.read(
                listGridProvider,
              );
            },
            icon: isGrid
                ? const Icon(Icons.list_alt_rounded)
                : const Icon(Icons.grid_view),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPoems = ref.watch(selectedPoemsProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => ref.read(selectedPoemsProvider.notifier).clear(),
          ),
          Text(
            selectedPoems.length.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Symbols.restore_rounded),
            onPressed: () => _restore(context, selectedPoems, ref),
          ),

          IconButton(
            icon: const Icon(Symbols.delete_forever_rounded),
            onPressed: () => _showWarning(context, selectedPoems, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    List<PoemModel> poems,
    WidgetRef ref,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await locator<Database>().restorePoems(poems);

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text("Restored from bin"),
        duration: Duration(seconds: 3),
      ),
    );
    ref.read(selectedPoemsProvider.notifier).clear();
  }

  void _showWarning(
    BuildContext context,
    List<PoemModel> selectedPoems,
    WidgetRef ref,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Do you really want to delete them permanently?"),
        content: const Text(
          "There would be no other way to get back your poems"
          " once deleted permanently. Are you really sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => _delete(context, selectedPoems, ref),
            child: const Text("Yes"),
          ),
          FilledButton(onPressed: () => context.pop(), child: const Text("No")),
        ],
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    List<PoemModel> selectedPoems,
    WidgetRef ref,
  ) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await locator<Database>().hardDeletePoems(selectedPoems);

    final String msg = result == 0 ? "Couldn't delete" : "Deleted";

    navigator.pop();
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 3)),
    );
    ref.read(selectedPoemsProvider.notifier).clear();
  }
}

class _CBody extends ConsumerWidget {
  const _CBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(listGridProvider);
    final poems = ref.watch(streamBinProvider);
    final selectedPoems = ref.watch(selectedPoemsProvider);
    final multiSelectedEnabled = ref.watch(multiSelectEnabledProvider);

    return poems.when(
      data: (poems) {
        if (poems.isEmpty) {
          return Center(
            child: Text(
              "No poems in bin",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
        return _PoemsLayout(
          isGrid: isGrid,
          itemCount: poems.length,
          itemBuilder: (context, index) {
            final poem = poems[index];
            final isSelected =
                selectedPoems.indexWhere((t) => t.id == poem.id) != -1;

            return Padding(
              padding: !isGrid
                  ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                  : EdgeInsets.zero,
              child: PoemCard(
                model: poem,
                isSelected: isSelected,
                key: ValueKey("${poem.lastEdit}-${poem.id}"),
                onPressed: () {
                  if (multiSelectedEnabled) {
                    ref.read(selectedPoemsProvider.notifier).toggle(poem);
                    return;
                  }
                  context.push(
                    ReaderScreen.route(poem.id!, bin: true),
                    extra: poem,
                  );
                },
                onLongPress: () {
                  ref.read(selectedPoemsProvider.notifier).toggle(poem);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(e.toString() + st.toString())),
    );
  }
}

class _PoemsLayout extends StatelessWidget {
  const _PoemsLayout({
    required this.isGrid,
    required this.itemBuilder,
    required this.itemCount,
  });
  final bool isGrid;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isGrid) {
          final int columns = (constraints.maxWidth / 180).floor().clamp(2, 6);
          return MasonryGridView.count(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            padding: const EdgeInsets.all(10.0),
            mainAxisSpacing: 10,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          );
        } else {
          return ListView.builder(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        }
      },
    );
  }
}
