import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/config.dart';
import '../../../init_get_it.dart';
import '../../../providers/list_grid_provider.dart';
import '../../profile_screen/profile_screen.dart';

class CAppBar extends StatelessWidget {
  const CAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _imagePath = locator<Config>().profile;
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
            style: Theme.of(context)
                .accentTextTheme
                .headline3
                .copyWith(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read(listGridProvider).state =
                  !context.read(listGridProvider).state;
            },
            icon: Consumer(
              builder: (context, watch, child) {
                final _isList = watch(listGridProvider).state;
                return _isList
                    ? const Icon(Icons.list_alt_rounded)
                    : const Icon(Icons.grid_view);
              },
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundImage:
                  _imagePath != null ? FileImage(File(_imagePath)) : null,
              child: _imagePath == null
                  ? const Icon(
                      Icons.person_add,
                      size: 100,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
