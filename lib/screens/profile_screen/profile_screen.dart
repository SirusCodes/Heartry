import 'dart:io';

import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/config.dart';
import '../../providers/shared_prefs_provider.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';
import '../../widgets/profile_update_dialog.dart';

const String noNameError = "Please enter your name...";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;

  late String _name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _name = context.read(sharedPrefsProvider).name!;
    _nameController = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          final name = _nameController.text;
          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(8.0),
                content: const Text(noNameError),
              ),
            );

            return Future.value(false);
          }
          if (_name != _nameController.text)
            context.read(sharedPrefsProvider).name = _nameController.text;

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
                  final _imagePath = watch(configProvider).profile;
                  return Badge(
                    badgeColor: Colors.deepPurple,
                    badgeContent: IconButton(
                      constraints:
                          const BoxConstraints(maxWidth: 40, minWidth: 35),
                      icon: const Icon(Icons.camera_alt_rounded),
                      onPressed: () => _showChangeProfileDialog(context),
                    ),
                    position: BadgePosition.bottomEnd(bottom: 6, end: 6),
                    child: CircleAvatar(
                      maxRadius: 100,
                      minRadius: 80,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath))
                          : null,
                      child: _imagePath == null
                          ? const Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.white,
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
      bottomNavigationBar:
          Platform.isIOS ? const OnlyBackButtonBottomAppBar() : null,
    );
  }

  Future _showChangeProfileDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const ProfileUpdateDialog(),
    );
  }
}
