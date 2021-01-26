import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/config.dart';
import '../../init_get_it.dart';
import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _nameController;

  String _name;

  final _config = locator<Config>();

  @override
  void initState() {
    super.initState();
    _name = _config.name;
    _nameController = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    if (_name != _nameController.text) _config.name = _nameController.text;

    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: CScreenTitle(title: "Profile"),
            ),
            GestureDetector(
              onTap: () => _showChangeProfileDialog(context),
              child: Consumer(
                builder: (context, watch, child) {
                  final _imagePath = watch(configProvider).profile;
                  return CircleAvatar(
                    maxRadius: 100,
                    minRadius: 80,
                    backgroundImage:
                        _imagePath != null ? FileImage(File(_imagePath)) : null,
                    child: _imagePath == null
                        ? const Icon(
                            Icons.person_add,
                            size: 100,
                          )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
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
      bottomNavigationBar: const OnlyBackButtonBottomAppBar(),
    );
  }

  Future _showChangeProfileDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 10,
        ),
        children: [
          _buildDialogButton(
            context,
            onPressed: () async {
              final picker = ImagePicker();
              final pickedImage =
                  await picker.getImage(source: ImageSource.gallery);
              await _setImage(context, pickedImage);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.photo_library),
            text: "Add from gallery",
          ),
          _buildDialogButton(
            context,
            onPressed: () async {
              final picker = ImagePicker();
              final pickedImage =
                  await picker.getImage(source: ImageSource.camera);
              await _setImage(context, pickedImage);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.camera_alt),
            text: "Capture from camera",
          ),
          _buildDialogButton(
            context,
            onPressed: () {
              context.read(configProvider).profile = null;
              Navigator.pop(context);
            },
            icon: const Icon(Icons.remove_circle),
            text: "Remove profile",
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildDialogButton(
    BuildContext context, {
    @required VoidCallback onPressed,
    @required Icon icon,
    @required String text,
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

  Future<void> _setImage(BuildContext context, PickedFile pickedImage) async {
    if (pickedImage == null) return;

    imageCache.clear();

    final directory = await getApplicationDocumentsDirectory();
    final file = p.basename(pickedImage.path);

    final imageSaved = join(directory.path, file);
    final image = await File(imageSaved).writeAsBytes(
      await pickedImage.readAsBytes(),
    );

    context.read(configProvider).profile = image.path;
  }
}
