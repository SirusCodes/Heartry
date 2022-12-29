import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/config.dart';
import '../../init_get_it.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import '../../widgets/profile_update_dialog.dart';

const String noNameError = "Please enter your name...";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;

  late String _name;

  final Config _config = locator<Config>();

  @override
  void initState() {
    super.initState();
    _name = _config.name!;
    _nameController = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS;

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          final name = _nameController.text;
          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(noNameError)),
            );

            return Future.value(false);
          }
          if (_name != _nameController.text)
            _config.name = _nameController.text;

          return Future.value(true);
        },
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: CScreenTitle(title: "Profile"),
              ),
              Consumer(
                builder: (context, watch, child) {
                  final imagePath = watch(configProvider).profile;
                  return Badge(
                    badgeColor: theme.colorScheme.onPrimaryContainer,
                    badgeContent: IconButton(
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: theme.colorScheme.background,
                      ),
                      onPressed: () => _showChangeProfileDialog(context),
                    ),
                    position: BadgePosition.bottomEnd(bottom: 6, end: 6),
                    toAnimate: false,
                    child: CircleAvatar(
                      maxRadius: 100,
                      minRadius: 80,
                      backgroundImage:
                          imagePath != null ? FileImage(File(imagePath)) : null,
                      child: imagePath == null
                          ? Icon(
                              Icons.person,
                              size: 100,
                              color: theme.colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (value == null || value.isEmpty) return noNameError;
                    return null;
                  },
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }

  Future _showChangeProfileDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const ProfileUpdateDialog(),
    );
  }
}
