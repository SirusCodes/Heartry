import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../database/config.dart';

class ProfileUpdateDialog extends ConsumerWidget {
  const ProfileUpdateDialog({Key? key, this.color}) : super(key: key);

  final Color? color;

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

            if (pickedImage == null) return;

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

            if (pickedImage == null) return;

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
              context.read(configProvider).removeProfile();
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

  Future<void> _setImage(BuildContext context, PickedFile pickedImage) async {
    imageCache!.clear();
    context
        .read(configProvider)
        .setProfile(pickedImage.path, await pickedImage.readAsBytes());
  }
}
