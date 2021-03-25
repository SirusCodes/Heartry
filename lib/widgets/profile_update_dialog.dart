import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heartry/database/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileUpdateDialog extends ConsumerWidget {
  const ProfileUpdateDialog({Key key, this.color}) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _image = watch(configProvider);
    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 10,
      ),
      backgroundColor: color,
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
        if (_image.profile != null)
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

    final imageSaved = p.join(directory.path, file);
    final image = await File(imageSaved).writeAsBytes(
      await pickedImage.readAsBytes(),
    );

    context.read(configProvider).profile = image.path;
  }
}
