import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

  String _imagePath;
  String _name;

  final _config = locator<Config>();

  @override
  void initState() {
    super.initState();
    _imagePath = _config.profile;
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
        child: ListView(
          children: <Widget>[
            const CScreenTitle(title: "Profile"),
            GestureDetector(
              onTap: () => _setImage(),
              child: CircleAvatar(
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

  Future<void> _setImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final fileExtension = p.extension(pickedImage.path);

    final imageSaved = join(directory.path, "profile-picture$fileExtension");
    final image = await File(imageSaved).writeAsBytes(
      await pickedImage.readAsBytes(),
    );

    setState(() {
      _imagePath = image.path;
    });

    _config.profile = _imagePath;
  }
}
