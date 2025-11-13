import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:heartry/screens/poems_screen/providers/multi_select_provider.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../database/config.dart';
import '../../providers/app_version_manager_provider.dart';
import '../../providers/changelog_provider.dart';
import '../../providers/list_grid_provider.dart';
import '../../providers/stream_poem_provider.dart';
import '../../utils/share_helper.dart';
import '../../widgets/share_option_list.dart';
import '../profile_screen/profile_screen.dart';
import '../reader_screen/reader_screen.dart';
import '../settings_screen/settings_screen.dart';
import '../writing_screen/writing_screen.dart';
import 'widgets/poem_card.dart';

class PoemScreen extends ConsumerStatefulWidget {
  const PoemScreen({super.key});

  @override
  ConsumerState<PoemScreen> createState() => _PoemScreenState();
}

class _PoemScreenState extends ConsumerState<PoemScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkIfChangelog();
    });
  }

  Future<void> requestNotifPerm() {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final androidNotif = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()!;

    return androidNotif.requestNotificationsPermission();
  }

  Future<void> checkIfChangelog() {
    final appVersionManager = ref.read(appVersionManagerProvider);
    return appVersionManager.isAppUpdated().then((value) async {
      if (!value) return;
      await _showChangelogs();
      await requestNotifPerm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (_, __) => [
            const SliverToBoxAdapter(child: _CAppBar()),
          ],
          body: const _CBody(),
        ),
      ),
      floatingActionButton: OpenContainer(
        closedColor: Colors.transparent,
        closedElevation: 0,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        openBuilder: (_, __) => const WritingScreen(),
        closedBuilder: (_, __) => AbsorbPointer(
          child: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangelogs() async {
    return showDialog(
      context: context,
      builder: (_) => const Dialog(child: _ChangelogDialog()),
    );
  }
}

class _ChangelogDialog extends StatelessWidget {
  const _ChangelogDialog();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final changelog = ref.watch(changelogProvider);
                return changelog.when(
                  data: (value) => Column(
                    children: [
                      Text(
                        "Changelogs",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Divider(),
                      Expanded(child: Markdown(data: value)),
                    ],
                  ),
                  error: (Object error, StackTrace stackTrace) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Cannot fetch changelogs"),
                      ElevatedButton(
                        onPressed: () {
                          const githubChangelogUrl =
                              "https://github.com/SirusCodes/Heartry/blob/main/CHANGELOG.md";
                          launchUrlString(githubChangelogUrl);
                        },
                        child: const Text("Open changelogs in browser"),
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
              FilledButton(
                onPressed: () => launchUrlString(
                  "https://t.me/heartry",
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text("Join Telegram Group"),
              ),
            ],
          ),
        ],
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
    final imagePath =
        ref //
            .watch(configProvider)
            .whenOrNull(data: (data) => data.profile);
    final isGrid = ref.watch(listGridProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Heartry",
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
          _SearchIcon(isGrid: isGrid),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundImage: imagePath != null
                  ? FileImage(File(imagePath))
                  : null,
              child: imagePath == null ? const Icon(Icons.person) : null,
            ),
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
          if (selectedPoems.length == 1) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareClicked(context, selectedPoems.first),
            ),
            IconButton(
              icon: const Icon(Icons.remove_red_eye_rounded),
              onPressed: () =>
                  _navigateToReaderScreen(context, selectedPoems.first),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showWarning(context, selectedPoems, ref),
          ),
        ],
      ),
    );
  }

  void _shareClicked(BuildContext context, PoemModel poem) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final poet =
              ref //
                  .watch(configProvider)
                  .whenOrNull(data: (data) => data.name);

          return ShareOptionList(
            onShareAsImage: () => ShareHelper.shareAsImage(
              context,
              title: poem.title,
              poem: poem.poem,
              poet: poet ?? "Unknown",
            ),
            onShareAsText: () => ShareHelper.shareAsText(
              title: poem.title,
              poem: poem.poem,
              poet: poet ?? "Unknown",
            ),
          );
        },
      ),
    );
  }

  void _navigateToReaderScreen(BuildContext context, PoemModel poem) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(model: poem)),
    );
  }

  void _showWarning(
    BuildContext context,
    List<PoemModel> selectedPoems,
    WidgetRef ref,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Do you really want to delete it?"),
        content: const Text(
          "There would be no other way to get back you art."
          " Are you really sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => _delete(context, selectedPoems, ref),
            child: const Text("Yes"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
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

    final result = await locator<Database>().deletePoems(
      selectedPoems.map((p) => p.id!),
    );

    final String msg = result == 0 ? "Failed to delete" : "Deleted";

    navigator.pop();
    scaffoldMessenger.showSnackBar(SnackBar(content: Text(msg)));
    ref.read(selectedPoemsProvider.notifier).clear();
  }
}

class _SearchIcon extends StatelessWidget {
  const _SearchIcon({required this.isGrid});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      isFullScreen: true,
      builder: (context, controller) {
        return IconButton(
          onPressed: () {
            controller.openView();
          },
          icon: Icon(Icons.search),
        );
      },
      suggestionsBuilder: (context, controller) async {
        final query = controller.text;
        if (query.isEmpty) return [];

        final poems = await locator<Database>().searchPoems(query);

        return poems.map(
          (poem) => PoemCard(
            model: poem,
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => WritingScreen(model: poem)),
              );
            },
          ),
        );
      },
      viewBuilder: (suggestions) => _PoemsLayout(
        isGrid: isGrid,
        itemBuilder: (context, index) {
          final poems = suggestions.toList();

          return Padding(
            padding: !isGrid
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                : EdgeInsets.zero,
            child: poems[index],
          );
        },
        itemCount: suggestions.length,
      ),
    );
  }
}

class _CBody extends ConsumerWidget {
  const _CBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(listGridProvider);
    final poems = ref.watch(streamPoemProvider);
    final selectedPoems = ref.watch(selectedPoemsProvider);
    final multiSelectedEnabled = ref.watch(multiSelectEnabledProvider);

    return poems.when(
      data: (poems) {
        if (poems.isEmpty) {
          return InkWell(
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const WritingScreen()),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("🥺", style: TextStyle(fontSize: 100)),
                const SizedBox(height: 10),
                Text(
                  "No poems yet...",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ],
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
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WritingScreen(model: poem),
                    ),
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
    return isGrid
        ? MasonryGridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            padding: const EdgeInsets.all(10.0),
            mainAxisSpacing: 10,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          )
        : ListView.builder(itemCount: itemCount, itemBuilder: itemBuilder);
  }
}
