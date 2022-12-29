import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../database/config.dart';
import '../../providers/list_grid_provider.dart';
import '../../providers/stream_poem_provider.dart';
import '../profile_screen/profile_screen.dart';
import '../settings_screen/settings_screen.dart';
import '../writing_screen/writing_screen.dart';
import 'widgets/poem_card.dart';

class PoemScreen extends StatelessWidget {
  const PoemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (_, __) => [
            const SliverToBoxAdapter(
              child: _CAppBar(),
            ),
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
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
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
}

class _CAppBar extends ConsumerWidget {
  const _CAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final imagePath = watch(configProvider).profile;
    final isList = watch(listGridProvider).state;

    return Padding(
      padding: const EdgeInsets.only(
        top: 15.0,
        left: 15.0,
        right: 15.0,
      ),
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
              context.read(listGridProvider).state =
                  !context.read(listGridProvider).state;
            },
            icon: isList
                ? const Icon(Icons.list_alt_rounded)
                : const Icon(Icons.grid_view),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundImage:
                  imagePath != null ? FileImage(File(imagePath)) : null,
              child: imagePath == null ? const Icon(Icons.person) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CBody extends ConsumerWidget {
  const _CBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final isGrid = watch(listGridProvider).state;
    final poems = watch(streamPoemProvider);

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
