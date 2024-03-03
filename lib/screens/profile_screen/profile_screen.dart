import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/config.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';

const String noNameError = "Please enter your name...";

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;

  late String _name;

  @override
  void initState() {
    super.initState();
    _name = ref.read(configProvider).requireValue.name!;
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
    final isAndroid = theme.platform == TargetPlatform.android;

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;

          final name = _nameController.text;
          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(noNameError)),
            );
            return;
          }
          if (_name != _nameController.text)
            ref.read(configProvider.notifier).name = _nameController.text;

          Navigator.pop(context);
        },
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: CScreenTitle(title: "Profile"),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final imagePath = ref //
                      .watch(configProvider)
                      .requireValue
                      .profile;

                  return Badge(
                    badgeStyle: BadgeStyle(
                      badgeColor: theme.colorScheme.onPrimaryContainer,
                    ),
                    badgeContent: IconButton(
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: theme.colorScheme.background,
                      ),
                      onPressed: () => _showChangeProfileDialog(ref),
                    ),
                    position: BadgePosition.bottomEnd(bottom: 6, end: 6),
                    badgeAnimation: const BadgeAnimation.scale(
                      toAnimate: false,
                    ),
                    child: CircleAvatar(
                      maxRadius: 100,
                      minRadius: 80,
                      backgroundImage:
                          imagePath != null ? FileImage(File(imagePath)) : null,
                      child: isAndroid
                          ? FutureBuilder(
                              future: _retriveImage(ref),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return imagePath == null
                                      ? const Icon(Icons.person, size: 100)
                                      : const SizedBox.shrink();
                                }
                                return const CircularProgressIndicator();
                              },
                            )
                          : imagePath == null
                              ? const Icon(Icons.person, size: 100)
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

  Future<void> _retriveImage(WidgetRef ref) async {
    final config = ref.read(configProvider.notifier);
    final retrievedImage = await ImagePicker().retrieveLostData();

    if (retrievedImage.isEmpty) return;

    final image = retrievedImage.file;
    if (image == null) return;

    config.profile = await _saveImageInAppStorage(image);
  }

  Future<void> _showChangeProfileDialog(WidgetRef ref) async {
    final config = ref.read(configProvider.notifier);
    final file = await showDialog<XFile>(
      context: context,
      builder: (context) => const _ProfileUpdateDialog(),
    );

    if (file == null) return;

    config.profile = await _saveImageInAppStorage(file);
  }

  Future<String> _saveImageInAppStorage(XFile pickedImage) async {
    imageCache.clear();

    final directory = await getApplicationDocumentsDirectory();
    final file = p.basename(pickedImage.path);

    final imageSaved = p.join(directory.path, file);
    final image = await File(imageSaved).writeAsBytes(
      await pickedImage.readAsBytes(),
    );

    return image.path;
  }
}

class _ProfileUpdateDialog extends StatelessWidget {
  const _ProfileUpdateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 10,
      ),
      children: [
        _buildDialogButton(
          context,
          onPressed: () => _updateImage(context, ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          text: "Add from gallery",
        ),
        _buildDialogButton(
          context,
          onPressed: () => _updateImage(context, ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
          text: "Capture from camera",
        ),
        Consumer(
          builder: (context, ref, child) {
            return ref.watch(configProvider).when(
                  data: (image) {
                    if (image.profile != null)
                      return _buildDialogButton(
                        context,
                        onPressed: () {
                          ref.read(configProvider.notifier).profile = null;
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.remove_circle),
                        text: "Remove profile",
                      );
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                );
          },
        ),
      ],
    );
  }

  ElevatedButton _buildDialogButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required Icon icon,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          icon,
          const Spacer(),
          Text(text),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> _updateImage(BuildContext context, ImageSource source) async {
    final navigator = Navigator.of(context);
    final picker = ImagePicker();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final pickedImage = await picker.pickImage(
        source: source,
        requestFullMetadata: false,
        imageQuality: 20,
      );

      navigator.pop(pickedImage);
    } on PlatformException {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Permission denied")),
      );
    }
  }
}
